# GoodleadsEx

Elixir client for the GoodLeads API. Generated at compile time from the OpenAPI specification.

## Installation

Add `goodleads_ex` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:goodleads_ex, "~> 0.1.0"}
  ]
end
```

## Configuration

### Application config

```elixir
# config/config.exs
config :goodleads_ex,
  base_url: "http://localhost:4000",
  api_key: "your-api-key"
```

### Runtime / per-request

```elixir
client = GoodleadsEx.client(
  base_url: "http://localhost:4000",
  api_key: "sk_your_secret_key"
)
```

You can also pass `req_options` to customize the underlying [Req](https://hexdocs.pm/req) HTTP client:

```elixir
client = GoodleadsEx.client(
  api_key: "sk_...",
  req_options: [receive_timeout: 30_000]
)
```

## Usage

Every function takes a `%GoodleadsEx.Client{}` as the first argument, followed by path parameters, and returns `{:ok, struct}` or `{:error, reason}`.

```elixir
client = GoodleadsEx.client(api_key: "sk_...")

# List leads
{:ok, response} = GoodleadsEx.list_leads(client, "my-account")

# Create a lead
{:ok, response} = GoodleadsEx.create_lead(client, "my-account", %{
  first_name: "Jane",
  last_name: "Doe",
  email: "jane@example.com",
  phone: "+15551234567"
})

# Get a company
{:ok, company} = GoodleadsEx.get_company(client, "my-account", "company-id")

# Create an order
{:ok, order} = GoodleadsEx.create_order(client, "my-account", "company-id", %{
  quantity: 10,
  criteria: "service_type == 'hvac_install'"
})

# Activate / pause orders
{:ok, order} = GoodleadsEx.activate_order(client, "my-account", "company-id", "order-id")
{:ok, order} = GoodleadsEx.pause_order(client, "my-account", "company-id", "order-id")

# Phone verification flow
{:ok, _} = GoodleadsEx.verify_lead_phone(client, "my-account", "lead-id")
{:ok, _} = GoodleadsEx.confirm_lead_phone(client, "my-account", "lead-id", %{code: "123456"})
```

## Error handling

API errors return `{:error, %{status: integer, body: map}}`:

```elixir
case GoodleadsEx.create_lead(client, "my-account", params) do
  {:ok, result} ->
    # handle success

  {:error, %{status: 422, body: body}} ->
    # validation error

  {:error, %{status: 401}} ->
    # invalid API key

  {:error, %{status: 429}} ->
    # rate limited

  {:error, %Req.TransportError{reason: reason}} ->
    # connection error (:econnrefused, :timeout, etc.)
end
```

## Response types

All responses are typed structs under `GoodleadsEx.Schemas`. Schemas are generated at compile time from `openapi.json` and recompile automatically when the spec changes.

| Function | Response struct |
|----------|---------------|
| `list_leads/2` | `ListLeadsResponse` |
| `create_lead/3` | `CreateLeadResponse` |
| `update_lead/4` | `UpdateLeadResponse` |
| `qualify_lead/3` | `QualifyLeadResponse` |
| `list_campaigns/2` | `CampaignListResponse` |
| `create_campaign/3` | `CampaignResponse` |
| `get_campaign/3` | `CampaignResponse` |
| `list_companies/2` | `CompanyListResponse` |
| `create_company/3` | `CompanyResponse` |
| `get_company/3` | `CompanyResponse` |
| `list_orders/3` | `OrderListResponse` |
| `create_order/4` | `OrderResponse` |
| `get_order/4` | `OrderResponse` |
| `activate_order/4` | `OrderResponse` |
| `pause_order/4` | `OrderResponse` |

## Testing

```sh
mix test
```

## Regenerating

Replace `openapi.json` and recompile — structs update automatically.

## License

See [LICENSE](LICENSE) for details.
