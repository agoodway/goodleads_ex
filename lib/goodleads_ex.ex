defmodule GoodleadsEx do
  @moduledoc """
  Elixir client for the GoodLeads API, generated from the OpenAPI specification.

  ## Configuration

      config :goodleads_ex,
        base_url: "http://localhost:4000",
        api_key: "your-api-key"

  ## Usage

      client = GoodleadsEx.client(api_key: "sk_...")
      {:ok, leads} = GoodleadsEx.list_leads(client, "my-account")
  """

  @spec_path Path.join([__DIR__, "..", "openapi.json"])
  @external_resource @spec_path
  @openapi_spec File.read!(@spec_path) |> Jason.decode!()

  alias GoodleadsEx.Client

  @doc "Create a new API client."
  def client(opts \\ []), do: Client.new(opts)

  # Compile-time helpers for deriving function names from operationIds
  @action_prefix %{
    "index" => "list",
    "show" => "get",
    "create" => "create",
    "update" => "update",
    "delete" => "delete"
  }

  @resource_singular %{
    "Campaigns" => "campaign",
    "Companies" => "company",
    "Leads" => "lead",
    "Orders" => "order",
    "Questionnaires" => "questionnaire",
    "Distributions" => "distribution",
    "LandingPages" => "landing_page",
    "Returns" => "return",
    "Sites" => "site",
    "Tags" => "tag",
    "Users" => "user"
  }

  @resource_plural %{
    "Campaigns" => "campaigns",
    "Companies" => "companies",
    "Leads" => "leads",
    "Orders" => "orders",
    "Questionnaires" => "questionnaires",
    "Distributions" => "distributions",
    "LandingPages" => "landing_pages",
    "Returns" => "returns",
    "Sites" => "sites",
    "Tags" => "tags",
    "Users" => "users"
  }

  # Explicit overrides for operationIds that don't map cleanly
  @func_name_overrides %{
    "LeadRouterWeb.Api.V1.QuestionnairesController.show_by_campaign" =>
      "get_campaign_questionnaire",
    "LeadRouterWeb.Api.V1.QuestionnairesController.schema" => "get_questionnaire_schema",
    "LeadRouterWeb.Api.V1.LeadsController.export_for_company" => "export_company_leads",
    "LeadRouterWeb.Api.V1.LeadsController.export" => "export_leads",
    "LeadRouterWeb.Api.V1.LeadsController.verify_phone" => "verify_lead_phone",
    "LeadRouterWeb.Api.V1.LeadsController.confirm_phone" => "confirm_lead_phone",
    "LeadRouterWeb.Api.V1.DistributionsController.undistributed" => "list_undistributed_leads",
    "LeadRouterWeb.Api.V1.CompaniesController.cap_status" => "get_company_cap_status",
    "LeadRouterWeb.Api.V1.ReturnsController.approve" => "approve_return",
    "LeadRouterWeb.Api.V1.ReturnsController.reject" => "reject_return",
    "LeadRouterWeb.Api.V1.OrdersController.cancel" => "cancel_order"
  }

  # Generate API functions from OpenAPI paths
  for {path, methods} <- @openapi_spec["paths"],
      {method, operation} <- methods,
      method in ~w(get post put patch delete) do
    operation_id = operation["operationId"]

    # Use override if available, otherwise derive from operationId
    func_name_str =
      case Map.get(@func_name_overrides, operation_id) do
        nil ->
          op_parts = String.split(operation_id, ".")
          action = List.last(op_parts)

          controller =
            op_parts
            |> Enum.at(-2)
            |> String.replace("Controller", "")

          singular = Map.get(@resource_singular, controller, String.downcase(controller))
          plural = Map.get(@resource_plural, controller, singular <> "s")

          case Map.get(@action_prefix, action) do
            "list" -> "list_#{plural}"
            prefix when prefix != nil -> "#{prefix}_#{singular}"
            nil -> "#{action}_#{singular}"
          end

        override ->
          override
      end

    func_name = String.to_atom(func_name_str)
    http_method = String.to_atom(method)
    summary = operation["summary"] || ""
    description = operation["description"] || ""

    # Find response schema ref
    response_ref =
      Enum.find_value(["200", "201"], fn code ->
        get_in(operation, ["responses", code, "content", "application/json", "schema", "$ref"])
      end)

    response_module =
      if response_ref do
        ref_name = response_ref |> String.split("/") |> List.last()
        Module.concat(GoodleadsEx.Schemas, ref_name)
      end

    has_body = operation["requestBody"] != nil

    # Extract path parameters
    path_params =
      Regex.scan(~r/\{(\w+)\}/, path)
      |> Enum.map(fn [_, name] -> name end)

    param_atoms = Enum.map(path_params, &String.to_atom/1)
    param_vars = Enum.map(param_atoms, &Macro.var(&1, nil))

    # Build a runtime path expression as an AST for string interpolation
    # Split path on {param} patterns, interleave with variable references
    path_parts = Regex.split(~r/\{(\w+)\}/, path, include_captures: true)

    path_ast =
      path_parts
      |> Enum.map(fn part ->
        case Regex.run(~r/^\{(\w+)\}$/, part) do
          [_, param_name] ->
            # Convert to a to_string call on the variable
            var = Macro.var(String.to_atom(param_name), nil)
            quote do: to_string(unquote(var))

          nil ->
            part
        end
      end)

    # Build a single interpolated string expression
    path_concat =
      Enum.reduce(path_ast, fn
        part, acc ->
          quote do: unquote(acc) <> unquote(part)
      end)

    cond do
      response_module == nil && has_body ->
        @doc "#{summary}\n\n#{description}"
        def unquote(func_name)(%Client{} = client, unquote_splicing(param_vars), params)
            when is_map(params) do
          path = unquote(path_concat)

          case Client.request(client, unquote(http_method), path, json: params) do
            {:ok, _body} -> :ok
            error -> error
          end
        end

      response_module == nil ->
        @doc "#{summary}\n\n#{description}"
        def unquote(func_name)(%Client{} = client, unquote_splicing(param_vars)) do
          path = unquote(path_concat)

          case Client.request(client, unquote(http_method), path) do
            {:ok, _body} -> :ok
            error -> error
          end
        end

      has_body ->
        @doc "#{summary}\n\n#{description}"
        def unquote(func_name)(%Client{} = client, unquote_splicing(param_vars), params)
            when is_map(params) do
          path = unquote(path_concat)

          case Client.request(client, unquote(http_method), path, json: params) do
            {:ok, body} when is_map(body) ->
              {:ok, unquote(response_module).from_map(body)}

            error ->
              error
          end
        end

      true ->
        @doc "#{summary}\n\n#{description}"
        def unquote(func_name)(%Client{} = client, unquote_splicing(param_vars)) do
          path = unquote(path_concat)

          case Client.request(client, unquote(http_method), path) do
            {:ok, body} when is_map(body) ->
              {:ok, unquote(response_module).from_map(body)}

            error ->
              error
          end
        end
    end
  end
end
