module ContextsHelper
  def link_to_context(ctx)
    name, perma = ctx ? [ctx.name, ctx.permalink] : [:etc, :etc]
    link_to h(name), context_path(perma)
  end
end
