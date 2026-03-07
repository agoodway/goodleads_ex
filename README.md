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
account = "my-account"
```

### Leads

```elixir
# List all leads for an account
{:ok, %{data: leads, meta: %{"total_count" => count}}} =
  GoodleadsEx.list_leads(client, account)

# Create a lead — returns an id and a JWT token for lead-scoped operations
{:ok, %{id: lead_id, token: jwt}} =
  GoodleadsEx.create_lead(client, account, %{
    first_name: "Jane",
    last_name: "Doe",
    email: "jane@example.com",
    phone: "+15551234567",
    city: "Denver",
    state: "CO",
    zip: "80202",
    data: %{service_type: "hvac_install", sqft: 2400},
    metadata: %{utm_source: "google", fbclid: "abc123"},
    campaign_id: "campaign-uuid",
    questionnaire_id: "questionnaire-uuid"
  })

# Update a lead
{:ok, %{id: ^lead_id, first_name: "Janet"}} =
  GoodleadsEx.update_lead(client, account, lead_id, %{
    first_name: "Janet",
    data: %{service_type: "hvac_repair"}
  })

# Phone verification flow
{:ok, %{message: "Verification code sent"}} =
  GoodleadsEx.verify_lead_phone(client, account, lead_id)

{:ok, %{phone_verified: true}} =
  GoodleadsEx.confirm_lead_phone(client, account, lead_id, %{code: "123456"})

# Qualify a lead — triggers distribution and returns buyer match if found
{:ok, %{lead: qualified_lead, buyer: buyer}} =
  GoodleadsEx.qualify_lead(client, account, lead_id)

# buyer is a %BuyerData{company_id: "...", company_name: "..."} or nil

# Export leads as CSV
:ok = GoodleadsEx.export_leads(client, account)
```

### Companies

```elixir
# List companies
{:ok, %{data: companies}} = GoodleadsEx.list_companies(client, account)

# Create a company
{:ok, company} =
  GoodleadsEx.create_company(client, account, %{
    name: "ACME HVAC Services",
    email: "info@acmehvac.com",
    phone: "+15559876543",
    status: "active"
  })

company.id   #=> "550e8400-..."
company.name #=> "ACME HVAC Services"

# Get / update / delete
{:ok, company} = GoodleadsEx.get_company(client, account, company.id)

{:ok, updated} =
  GoodleadsEx.update_company(client, account, company.id, %{
    name: "ACME HVAC Pro"
  })

:ok = GoodleadsEx.delete_company(client, account, company.id)

# Export leads for a specific company
:ok = GoodleadsEx.export_company_leads(client, account, company.id)
```

### Orders

```elixir
# List orders for a company
{:ok, %{data: orders}} = GoodleadsEx.list_orders(client, account, company_id)

# Create an order with lead-matching criteria
{:ok, order} =
  GoodleadsEx.create_order(client, account, company_id, %{
    quantity: 10,
    criteria: "service_type == 'hvac_install'"
  })

order.status           #=> "active"
order.quantity         #=> 10
order.distributed_count #=> 0

# Get / update an order
{:ok, order} = GoodleadsEx.get_order(client, account, company_id, order.id)

{:ok, order} =
  GoodleadsEx.update_order(client, account, company_id, order.id, %{
    quantity: 20
  })

# Pause and reactivate
{:ok, %{status: "paused"}} =
  GoodleadsEx.pause_order(client, account, company_id, order.id)

{:ok, %{status: "active"}} =
  GoodleadsEx.activate_order(client, account, company_id, order.id)
```

### Campaigns

```elixir
# List campaigns
{:ok, %{data: campaigns}} = GoodleadsEx.list_campaigns(client, account)

# Create a campaign
{:ok, campaign} =
  GoodleadsEx.create_campaign(client, account, %{
    name: "Summer HVAC Push",
    slug: "summer-hvac",
    description: "Summer 2026 lead gen campaign",
    status: "active"
  })

campaign.slug       #=> "summer-hvac"
campaign.lead_count #=> 0

# Get / update by slug
{:ok, campaign} = GoodleadsEx.get_campaign(client, account, "summer-hvac")

{:ok, campaign} =
  GoodleadsEx.update_campaign(client, account, "summer-hvac", %{
    description: "Updated description"
  })
```

### Questionnaires

```elixir
# List questionnaires
{:ok, %{data: questionnaires}} = GoodleadsEx.list_questionnaires(client, account)

# Create a questionnaire
{:ok, questionnaire} =
  GoodleadsEx.create_questionnaire(client, account, %{
    name: "HVAC Service Form",
    slug: "hvac-service",
    questions: [%{type: "text", label: "What service do you need?"}]
  })

# Get / update by slug
{:ok, q} = GoodleadsEx.get_questionnaire(client, account, "hvac-service")

{:ok, q} =
  GoodleadsEx.update_questionnaire(client, account, "hvac-service", %{
    name: "Updated Form Name"
  })

# Get a questionnaire via its campaign
{:ok, q} = GoodleadsEx.get_campaign_questionnaire(client, account, "summer-hvac", "hvac-service")

# Get the questionnaire JSON schema
{:ok, _schema} = GoodleadsEx.get_questionnaire_schema(client)
```

### Distributions

```elixir
# List all distributions
{:ok, %{data: distributions}} = GoodleadsEx.list_distributions(client, account)

# Each distribution links a lead to an order
# distribution.lead => %Lead{}, distribution.order => %Order{}

# Get a single distribution
{:ok, dist} = GoodleadsEx.get_distribution(client, account, distribution_id)

# List leads that haven't been distributed yet
{:ok, %{data: undistributed}} = GoodleadsEx.list_undistributed_leads(client, account)
```

### Sites and Landing Pages

```elixir
# List sites
{:ok, %{data: sites}} = GoodleadsEx.list_sites(client, account)

# Get site config (colors, fonts, logos, analytics)
{:ok, site} = GoodleadsEx.get_site(client, account, "my-site")
site.site_name          #=> "HVAC Henry"
site.ga_measurement_id  #=> "G-XXXXXXXXXX"
site.colors             #=> %{"primary" => "#2563eb", ...}

# List / get landing pages
{:ok, %{data: pages}} = GoodleadsEx.list_landing_pages(client, account)
{:ok, page} = GoodleadsEx.get_landing_page(client, account, "free-quote")
page.campaign_slug      #=> "summer-hvac"
page.questionnaire_slug #=> "hvac-service"
```

### Account Members

```elixir
# List users
{:ok, %{data: members}} = GoodleadsEx.list_users(client, account)

# Create a user
{:ok, member} =
  GoodleadsEx.create_user(client, account, %{
    email: "technician@acmehvac.com",
    role: "member"
  })

# Get / update / delete
{:ok, member} = GoodleadsEx.get_user(client, account, member_id)

{:ok, member} =
  GoodleadsEx.update_user(client, account, member_id, %{role: "admin"})

:ok = GoodleadsEx.delete_user(client, account, member_id)
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
| **Leads** | |
| `list_leads/2` | `ListLeadsResponse` (data: [Lead], meta) |
| `create_lead/3` | `CreateLeadResponse` (id, token) |
| `update_lead/4` | `UpdateLeadResponse` (Lead fields) |
| `qualify_lead/3` | `QualifyLeadResponse` (lead, buyer) |
| `verify_lead_phone/3` | `VerifyPhoneResponse` (message) |
| `confirm_lead_phone/4` | `ConfirmPhoneResponse` (Lead fields) |
| `export_leads/2` | `:ok` |
| `export_company_leads/3` | `:ok` |
| `list_undistributed_leads/2` | `UndistributedLeadListResponse` (data: [Lead]) |
| **Companies** | |
| `list_companies/2` | `CompanyListResponse` (data: [Company]) |
| `create_company/3` | `CompanyResponse` (Company fields) |
| `get_company/3` | `CompanyResponse` (Company fields) |
| `update_company/4` | `CompanyResponse` (Company fields) |
| `delete_company/3` | `:ok` |
| **Orders** | |
| `list_orders/3` | `OrderListResponse` (data: [OrderSummary]) |
| `create_order/4` | `OrderResponse` (Order fields) |
| `get_order/4` | `OrderResponse` (Order fields) |
| `update_order/5` | `OrderResponse` (Order fields) |
| `activate_order/4` | `OrderResponse` (Order fields) |
| `pause_order/4` | `OrderResponse` (Order fields) |
| **Campaigns** | |
| `list_campaigns/2` | `CampaignListResponse` (data: [Campaign]) |
| `create_campaign/3` | `CampaignResponse` (Campaign fields) |
| `get_campaign/3` | `CampaignResponse` (Campaign fields) |
| `update_campaign/4` | `CampaignResponse` (Campaign fields) |
| **Questionnaires** | |
| `list_questionnaires/2` | `ListQuestionnairesResponse` (data: [Questionnaire]) |
| `create_questionnaire/3` | `QuestionnaireResponse` (Questionnaire fields) |
| `get_questionnaire/3` | `QuestionnaireResponse` (Questionnaire fields) |
| `update_questionnaire/4` | `QuestionnaireResponse` (Questionnaire fields) |
| `get_campaign_questionnaire/4` | `QuestionnaireResponse` (Questionnaire fields) |
| `get_questionnaire_schema/1` | `:ok` |
| **Distributions** | |
| `list_distributions/2` | `DistributionListResponse` (data: [Distribution]) |
| `get_distribution/3` | `DistributionResponse` (Distribution fields) |
| **Sites & Landing Pages** | |
| `list_sites/2` | `SiteListResponse` (data: [Site]) |
| `get_site/3` | `SiteResponse` (site config fields) |
| `list_landing_pages/2` | `LandingPageListResponse` (data: [LandingPage]) |
| `get_landing_page/3` | `LandingPageResponse` (landing page fields) |
| **Account Members** | |
| `list_users/2` | `AccountMemberListResponse` (data: [AccountMember]) |
| `create_user/3` | `AccountMemberResponse` (AccountMember fields) |
| `get_user/3` | `AccountMemberResponse` (AccountMember fields) |
| `update_user/4` | `AccountMemberResponse` (AccountMember fields) |
| `delete_user/3` | `:ok` |

## Testing

```sh
mix test
```

## Regenerating

Replace `openapi.json` and recompile — structs update automatically.

## License

See [LICENSE](LICENSE) for details.
