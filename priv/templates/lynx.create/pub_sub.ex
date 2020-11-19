defmodule <%= inspect pub_sub.module %> do
  alias <%= inspect schema.module %>

  def <%= pub_sub.broadcast %>(<%= schema.singular %> = %<%= inspect schema.alias %>{}, message) do
    topic = <%= schema.singular %>_topic(<%= schema.singular %>)
    Phoenix.PubSub.broadcast(<%= inspect pub_sub.ctx_pub_sub %>, topic, {:<%= schema.singular %>, message})
    <%= schema.singular %>
  end

  def <%= schema.singular %>_topic(<%= schema.singular %> = %<%= inspect schema.alias %>{}) do
    "<%= schema.plural %>:#{<%= schema.singular %>.resource_id}"
  end

  def <%= schema.singular %>_topic(resource = %_ResourceSchema{}) do
    "<%= schema.plural %>:#{resource.id}"
  end
end
