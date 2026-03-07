defmodule GoodleadsEx.IntegrationTest do
  use ExUnit.Case, async: true
  use Mimic

  alias GoodleadsEx.Schemas

  setup :verify_on_exit!

  @client GoodleadsEx.client(base_url: "http://localhost:4000", api_key: "sk_test_123")
  @account "test-account"

  defp json_response(status, body) do
    {:ok, %Req.Response{status: status, body: body}}
  end

  describe "list_leads/2" do
    test "returns list of lead summaries on success" do
      expect(Req, :request, fn opts ->
        assert opts[:method] == :get
        assert opts[:url] == "http://localhost:4000/api/v1/accounts/test-account/leads"
        assert opts[:headers] == [{"authorization", "Bearer sk_test_123"}]

        json_response(200, %{
          "data" => [
            %{"id" => "lead-1", "first_name" => "Alice", "status" => "new"},
            %{"id" => "lead-2", "first_name" => "Bob", "status" => "qualified"}
          ]
        })
      end)

      assert {:ok, result} = GoodleadsEx.list_leads(@client, @account)
      assert %Schemas.ListLeadsResponse{} = result
      assert length(result.data) == 2
      assert hd(result.data).first_name == "Alice"
    end

    test "returns error on 401" do
      expect(Req, :request, fn _opts ->
        json_response(401, %{"error" => "unauthorized"})
      end)

      assert {:error, %{status: 401}} = GoodleadsEx.list_leads(@client, @account)
    end
  end

  describe "create_lead/3" do
    test "creates a lead and returns response" do
      expect(Req, :request, fn opts ->
        assert opts[:method] == :post
        assert opts[:url] == "http://localhost:4000/api/v1/accounts/test-account/leads"
        assert opts[:json] == %{first_name: "Jane", last_name: "Doe"}

        json_response(201, %{
          "data" => %{
            "id" => "new-lead-1",
            "first_name" => "Jane",
            "last_name" => "Doe",
            "status" => "new"
          }
        })
      end)

      assert {:ok, result} =
               GoodleadsEx.create_lead(@client, @account, %{
                 first_name: "Jane",
                 last_name: "Doe"
               })

      assert %Schemas.CreateLeadResponse{} = result
    end

    test "returns error on 422 validation failure" do
      expect(Req, :request, fn _opts ->
        json_response(422, %{
          "errors" => %{"first_name" => ["can't be blank"]}
        })
      end)

      assert {:error, %{status: 422, body: body}} =
               GoodleadsEx.create_lead(@client, @account, %{})

      assert body["errors"]["first_name"] == ["can't be blank"]
    end
  end

  describe "get_company/3" do
    test "returns company fields directly (allOf alias)" do
      expect(Req, :request, fn opts ->
        assert opts[:method] == :get
        assert opts[:url] == "http://localhost:4000/api/v1/accounts/test-account/companies/comp-1"

        json_response(200, %{
          "id" => "comp-1",
          "name" => "ACME HVAC",
          "status" => "active"
        })
      end)

      assert {:ok, result} = GoodleadsEx.get_company(@client, @account, "comp-1")
      assert %Schemas.CompanyResponse{} = result
      assert result.name == "ACME HVAC"
    end
  end

  describe "create_order/4" do
    test "creates an order under a company" do
      expect(Req, :request, fn opts ->
        assert opts[:method] == :post

        assert opts[:url] ==
                 "http://localhost:4000/api/v1/accounts/test-account/companies/comp-1/orders"

        json_response(201, %{
          "id" => "order-1",
          "status" => "active",
          "quantity" => 10
        })
      end)

      assert {:ok, result} =
               GoodleadsEx.create_order(@client, @account, "comp-1", %{quantity: 10})

      assert %Schemas.OrderResponse{} = result
    end
  end

  describe "activate_order/4" do
    test "activates an order (no request body)" do
      expect(Req, :request, fn opts ->
        assert opts[:method] == :post

        assert opts[:url] ==
                 "http://localhost:4000/api/v1/accounts/test-account/companies/comp-1/orders/order-1/activate"

        json_response(200, %{"id" => "order-1", "status" => "active"})
      end)

      assert {:ok, result} =
               GoodleadsEx.activate_order(@client, @account, "comp-1", "order-1")

      assert %Schemas.OrderResponse{} = result
    end
  end

  describe "transport errors" do
    test "returns error on connection failure" do
      expect(Req, :request, fn _opts ->
        {:error, %Req.TransportError{reason: :econnrefused}}
      end)

      assert {:error, %Req.TransportError{reason: :econnrefused}} =
               GoodleadsEx.list_leads(@client, @account)
    end

    test "returns error on timeout" do
      expect(Req, :request, fn _opts ->
        {:error, %Req.TransportError{reason: :timeout}}
      end)

      assert {:error, %Req.TransportError{reason: :timeout}} =
               GoodleadsEx.list_leads(@client, @account)
    end
  end

  describe "client configuration" do
    test "does not send auth header when api_key is nil" do
      client = GoodleadsEx.client(base_url: "http://localhost:4000")

      expect(Req, :request, fn opts ->
        assert opts[:headers] == []
        json_response(200, %{"data" => []})
      end)

      assert {:ok, _} = GoodleadsEx.list_leads(client, @account)
    end

    test "req_options are merged into requests" do
      client =
        GoodleadsEx.client(
          base_url: "http://localhost:4000",
          api_key: "sk_test",
          req_options: [receive_timeout: 30_000]
        )

      expect(Req, :request, fn opts ->
        assert opts[:receive_timeout] == 30_000
        json_response(200, %{"data" => []})
      end)

      assert {:ok, _} = GoodleadsEx.list_leads(client, @account)
    end
  end
end
