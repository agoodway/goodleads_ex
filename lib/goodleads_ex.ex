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
    "Buyers" => "buyer",
    "CallFlows" => "call_flow",
    "CampaignTrackingNumbers" => "campaign_tracking_number",
    "Campaigns" => "campaign",
    "Distributions" => "distribution",
    "FieldCatalog" => "field_catalog_entry",
    "LandingPages" => "landing_page",
    "Leads" => "lead",
    "Orders" => "order",
    "QuestionnaireExperiments" => "questionnaire_experiment",
    "QuestionnaireVariants" => "questionnaire_variant",
    "Questionnaires" => "questionnaire",
    "Returns" => "return",
    "Sites" => "site",
    "Tags" => "tag",
    "TrackedLinks" => "link",
    "TrackingNumbers" => "tracking_number",
    "Users" => "user",
    "Verticals" => "vertical"
  }

  @resource_plural %{
    "Buyers" => "buyers",
    "CallFlows" => "call_flows",
    "CampaignTrackingNumbers" => "campaign_tracking_numbers",
    "Campaigns" => "campaigns",
    "Distributions" => "distributions",
    "FieldCatalog" => "field_catalog",
    "LandingPages" => "landing_pages",
    "Leads" => "leads",
    "Orders" => "orders",
    "QuestionnaireExperiments" => "questionnaire_experiments",
    "QuestionnaireVariants" => "questionnaire_variants",
    "Questionnaires" => "questionnaires",
    "Returns" => "returns",
    "Sites" => "sites",
    "Tags" => "tags",
    "TrackedLinks" => "links",
    "TrackingNumbers" => "tracking_numbers",
    "Users" => "users",
    "Verticals" => "verticals"
  }

  # Explicit overrides for operationIds that don't map cleanly
  @func_name_overrides %{
    "LeadRouterWeb.Api.V1.BuyersController.cap_status" => "get_buyer_cap_status",
    "LeadRouterWeb.Api.V1.CallFlowsController.references" => "get_call_flow_references",
    "LeadRouterWeb.Api.V1.CallFlowsController.schema" => "get_call_flow_schema",
    "LeadRouterWeb.Api.V1.CallFlowsController.validate" => "validate_call_flow",
    "LeadRouterWeb.Api.V1.CampaignTrackingNumbersController.activate" =>
      "activate_campaign_tracking_number",
    "LeadRouterWeb.Api.V1.CampaignTrackingNumbersController.release" =>
      "release_campaign_tracking_number",
    "LeadRouterWeb.Api.V1.DistributionsController.undistributed" => "list_undistributed_leads",
    "LeadRouterWeb.Api.V1.ExternalRecordingController.complete" => "complete_lead_recording",
    "LeadRouterWeb.Api.V1.ExternalRecordingController.start" => "start_lead_recording",
    "LeadRouterWeb.Api.V1.GeoController.cities" => "list_geo_cities",
    "LeadRouterWeb.Api.V1.GeoController.states" => "list_geo_states",
    "LeadRouterWeb.Api.V1.LeadsController.check" => "check_lead",
    "LeadRouterWeb.Api.V1.LeadsController.check_host" => "check_lead_host",
    "LeadRouterWeb.Api.V1.LeadsController.confirm_consent" => "confirm_lead_consent",
    "LeadRouterWeb.Api.V1.LeadsController.confirm_consent_host" => "confirm_lead_consent_host",
    "LeadRouterWeb.Api.V1.LeadsController.confirm_phone" => "confirm_lead_phone",
    "LeadRouterWeb.Api.V1.LeadsController.confirm_phone_host" => "confirm_lead_phone_host",
    "LeadRouterWeb.Api.V1.LeadsController.create_host" => "create_lead_host",
    "LeadRouterWeb.Api.V1.LeadsController.export" => "export_leads",
    "LeadRouterWeb.Api.V1.LeadsController.export_for_buyer" => "export_buyer_leads",
    "LeadRouterWeb.Api.V1.LeadsController.qualify_host" => "qualify_lead_host",
    "LeadRouterWeb.Api.V1.LeadsController.sync_tags" => "sync_lead_tags",
    "LeadRouterWeb.Api.V1.LeadsController.update_host" => "update_lead_host",
    "LeadRouterWeb.Api.V1.LeadsController.upload_file" => "upload_lead_file",
    "LeadRouterWeb.Api.V1.LeadsController.upload_file_host" => "upload_lead_file_host",
    "LeadRouterWeb.Api.V1.LeadsController.verify_phone" => "verify_lead_phone",
    "LeadRouterWeb.Api.V1.LeadsController.verify_phone_host" => "verify_lead_phone_host",
    "LeadRouterWeb.Api.V1.OrdersController.activate" => "activate_order",
    "LeadRouterWeb.Api.V1.OrdersController.cancel" => "cancel_order",
    "LeadRouterWeb.Api.V1.OrdersController.pause" => "pause_order",
    "LeadRouterWeb.Api.V1.QuestionnaireExperimentsController.declare_winner" =>
      "declare_questionnaire_experiment_winner",
    "LeadRouterWeb.Api.V1.QuestionnaireExperimentsController.start" =>
      "start_questionnaire_experiment",
    "LeadRouterWeb.Api.V1.QuestionnaireExperimentsController.stop" =>
      "stop_questionnaire_experiment",
    "LeadRouterWeb.Api.V1.QuestionnaireVariantsController.create_draft" =>
      "create_questionnaire_variant_draft",
    "LeadRouterWeb.Api.V1.QuestionnaireVariantsController.discard_draft" =>
      "discard_questionnaire_variant_draft",
    "LeadRouterWeb.Api.V1.QuestionnaireVariantsController.draft" =>
      "get_questionnaire_variant_draft",
    "LeadRouterWeb.Api.V1.QuestionnaireVariantsController.publish_draft" =>
      "publish_questionnaire_variant_draft",
    "LeadRouterWeb.Api.V1.QuestionnaireVariantsController.save_draft" =>
      "save_questionnaire_variant_draft",
    "LeadRouterWeb.Api.V1.QuestionnaireVariantsController.start_over" =>
      "start_over_questionnaire_variant_draft",
    "LeadRouterWeb.Api.V1.QuestionnairesController.schema" => "get_questionnaire_schema",
    "LeadRouterWeb.Api.V1.QuestionnairesController.show_admin" => "get_questionnaire_admin",
    "LeadRouterWeb.Api.V1.QuestionnairesController.show_by_campaign" =>
      "get_campaign_questionnaire",
    "LeadRouterWeb.Api.V1.ReturnsController.approve" => "approve_return",
    "LeadRouterWeb.Api.V1.ReturnsController.reject" => "reject_return",
    "LeadRouterWeb.Api.V1.TrackedLinksController.clicks" => "list_link_clicks",
    "LeadRouterWeb.Api.V1.TrackingNumbersController.initialize_pool" =>
      "initialize_tracking_number_pool",
    "LeadRouterWeb.Api.V1.TrackingNumbersController.pool_health" =>
      "get_tracking_number_pool_health",
    "LeadRouterWeb.Api.V1.VersionController.show" => "get_version"
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

    # Extract query parameters
    query_params =
      (operation["parameters"] || [])
      |> Enum.filter(&(&1["in"] == "query"))
      |> Enum.map(&{String.to_atom(&1["name"]), &1["description"] || ""})

    has_query_params = query_params != []

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

    # Build query param documentation
    query_doc =
      if has_query_params do
        param_docs =
          query_params
          |> Enum.map(fn {name, desc} ->
            "  - `#{name}` - #{desc}"
          end)
          |> Enum.join("\n")

        "\n\n## Query Parameters\n\nPass as a keyword list in the last argument:\n\n#{param_docs}"
      else
        ""
      end

    cond do
      response_module == nil && has_body ->
        @doc "#{summary}\n\n#{description}#{query_doc}"
        def unquote(func_name)(%Client{} = client, unquote_splicing(param_vars), params)
            when is_map(params) do
          path = unquote(path_concat)

          case Client.request(client, unquote(http_method), path, json: params) do
            {:ok, _body} -> :ok
            error -> error
          end
        end

      response_module == nil && has_query_params ->
        @doc "#{summary}\n\n#{description}#{query_doc}"
        def unquote(func_name)(%Client{} = client, unquote_splicing(param_vars), opts \\ []) do
          path = unquote(path_concat)
          req_opts = if opts == [], do: [], else: [params: Map.new(opts)]

          case Client.request(client, unquote(http_method), path, req_opts) do
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
        @doc "#{summary}\n\n#{description}#{query_doc}"
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

      has_query_params ->
        @doc "#{summary}\n\n#{description}#{query_doc}"
        def unquote(func_name)(%Client{} = client, unquote_splicing(param_vars), opts \\ []) do
          path = unquote(path_concat)
          req_opts = if opts == [], do: [], else: [params: Map.new(opts)]

          case Client.request(client, unquote(http_method), path, req_opts) do
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
