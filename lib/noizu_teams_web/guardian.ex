defmodule NoizuTeamsWeb.Guardian do
  use Guardian, otp_app: :noizu_teams
  require Logger
  def subject_for_token(%NoizuTeams.User{identifier: id}, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = "ref.user." <> to_string(id)
    {:ok, sub}
  end
  def subject_for_token(_, _) do
    Logger.warn "INVALID SUBJECT FOR TOKEN"
    {:error, :reason_for_error}
  end

  def get_resource_by_id("ref.user." <> uuid) do
    with user = NoizuTeams.Repo.get(NoizuTeams.User, uuid) do
      Logger.warn("GOT RESOURCE #{inspect user}")
      {:ok, user}
    end
  end

  def get_resource_by_id(sub) do
    Logger.error("RESOURCE BY ID #{sub}")
    nil
  end

  def resource_from_claims(%{"sub" => id}) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In above `subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    NoizuTeamsWeb.Guardian.get_resource_by_id(id)
  end
  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end