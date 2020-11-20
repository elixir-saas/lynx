defmodule <%= inspect pub_sub.module %> do
  @moduledoc """
  PubSub helpers for <%= schema.singular %> messages.

  """

  alias <%= inspect schema.module %>

  @doc """
  Subscribes to messages for all <%= schema.plural %> that are associated with
  the given resource.

  """
  def <%= pub_sub.subscribe %>({:ok, subject}) do
    {:ok, <%= pub_sub.subscribe %>(subject)}
  end

  def <%= pub_sub.subscribe %>({:error, reason}) do
    {:error, reason}
  end

  def <%= pub_sub.subscribe %>(resource = %_ResourceSchema{}) do
    topic = <%= schema.singular %>_topic(resource)
    Phoenix.PubSub.subscribe(<%= inspect pub_sub.ctx_pub_sub %>, topic)
    resource
  end

  @doc """
  Broadcasts a message for a <%= schema.singular %> on the topic for the
  associated resource.

  """
  def <%= pub_sub.broadcast %>({:ok, subject}, message) do
    {:ok, <%= pub_sub.broadcast %>(subject, message)}
  end

  def <%= pub_sub.broadcast %>({:error, reason}, _message) do
    {:error, reason}
  end

  def <%= pub_sub.broadcast %>(<%= schema.singular %> = %<%= inspect schema.alias %>{}, message) do
    topic = <%= schema.singular %>_topic(<%= schema.singular %>)
    Phoenix.PubSub.broadcast(<%= inspect pub_sub.ctx_pub_sub %>, topic, {:<%= schema.singular %>, message})
    <%= schema.singular %>
  end

  defp <%= schema.singular %>_topic(<%= schema.singular %> = %<%= inspect schema.alias %>{}) do
    "<%= schema.plural %>:#{<%= schema.singular %>.resource_id}"
  end

  defp <%= schema.singular %>_topic(%_ResourceSchema{id: resource_id}) do
    "<%= schema.plural %>:#{resource_id}"
  end
end
