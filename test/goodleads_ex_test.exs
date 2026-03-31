defmodule GoodleadsExTest do
  use ExUnit.Case

  alias GoodleadsEx.Client
  alias GoodleadsEx.Schemas

  describe "client/1" do
    test "creates client with defaults" do
      client = GoodleadsEx.client()
      assert %Client{base_url: "http://localhost:4000", api_key: nil} = client
    end

    test "creates client with explicit options" do
      client = GoodleadsEx.client(base_url: "https://api.example.com", api_key: "sk_test")
      assert client.base_url == "https://api.example.com"
      assert client.api_key == "sk_test"
    end

    test "passes through req_options" do
      client = GoodleadsEx.client(req_options: [receive_timeout: 30_000])
      assert client.req_options == [receive_timeout: 30_000]
    end
  end

  describe "schema from_map/1" do
    test "Lead from_map converts flat fields" do
      map = %{
        "id" => "abc-123",
        "first_name" => "Jane",
        "last_name" => "Doe",
        "email" => "jane@example.com",
        "phone" => "555-1234",
        "status" => "qualified"
      }

      lead = Schemas.Lead.from_map(map)
      assert %Schemas.Lead{} = lead
      assert lead.id == "abc-123"
      assert lead.first_name == "Jane"
      assert lead.status == "qualified"
    end

    test "BuyerResponse from_map inherits Buyer fields via allOf" do
      map = %{
        "id" => "buyer-1",
        "name" => "ACME HVAC",
        "email" => "info@acme.com",
        "status" => "active"
      }

      result = Schemas.BuyerResponse.from_map(map)
      assert %Schemas.BuyerResponse{} = result
      assert result.name == "ACME HVAC"
      assert result.id == "buyer-1"
    end

    test "ListLeadsResponse from_map with array of lead refs" do
      map = %{
        "data" => [
          %{"id" => "lead-1", "first_name" => "Alice"},
          %{"id" => "lead-2", "first_name" => "Bob"}
        ]
      }

      result = Schemas.ListLeadsResponse.from_map(map)
      assert %Schemas.ListLeadsResponse{} = result
      assert [%Schemas.Lead{}, %Schemas.Lead{}] = result.data
      assert hd(result.data).first_name == "Alice"
    end

    test "from_map handles nil" do
      assert nil == Schemas.Lead.from_map(nil)
    end

    test "from_map ignores unknown fields" do
      result = Schemas.Lead.from_map(%{"id" => "abc", "unknown_field" => "ignored"})
      assert result.id == "abc"
    end
  end

  describe "generated API functions" do
    test "all expected CRUD functions are exported" do
      Code.ensure_loaded!(GoodleadsEx)

      assert function_exported?(GoodleadsEx, :list_leads, 2)
      assert function_exported?(GoodleadsEx, :create_lead, 3)
      assert function_exported?(GoodleadsEx, :update_lead, 4)
      assert function_exported?(GoodleadsEx, :qualify_lead, 3)

      assert function_exported?(GoodleadsEx, :list_campaigns, 2)
      assert function_exported?(GoodleadsEx, :create_campaign, 3)
      assert function_exported?(GoodleadsEx, :get_campaign, 3)
      assert function_exported?(GoodleadsEx, :update_campaign, 4)

      assert function_exported?(GoodleadsEx, :list_buyers, 2)
      assert function_exported?(GoodleadsEx, :create_buyer, 3)
      assert function_exported?(GoodleadsEx, :get_buyer, 3)
      assert function_exported?(GoodleadsEx, :update_buyer, 4)
      assert function_exported?(GoodleadsEx, :delete_buyer, 3)

      assert function_exported?(GoodleadsEx, :list_orders, 3)
      assert function_exported?(GoodleadsEx, :create_order, 4)
      assert function_exported?(GoodleadsEx, :get_order, 4)
      assert function_exported?(GoodleadsEx, :update_order, 5)
      assert function_exported?(GoodleadsEx, :activate_order, 4)
      assert function_exported?(GoodleadsEx, :pause_order, 4)

      assert function_exported?(GoodleadsEx, :verify_lead_phone, 3)
      assert function_exported?(GoodleadsEx, :confirm_lead_phone, 4)
      assert function_exported?(GoodleadsEx, :confirm_lead_consent, 4)
      assert function_exported?(GoodleadsEx, :list_undistributed_leads, 2)
      assert function_exported?(GoodleadsEx, :get_questionnaire_schema, 1)

      assert function_exported?(GoodleadsEx, :list_tracking_numbers, 3)
      assert function_exported?(GoodleadsEx, :create_tracking_number, 4)
      assert function_exported?(GoodleadsEx, :delete_tracking_number, 4)

      assert function_exported?(GoodleadsEx, :get_buyer_cap_status, 3)
      assert function_exported?(GoodleadsEx, :export_buyer_leads, 3)
    end
  end
end
