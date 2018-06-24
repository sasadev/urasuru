module BreadcrumbsOnRails
  module Custom
    class AdminBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
      def render
        @context.render "/admin/breadcrumbs", elements: @elements
      end
    end
  end
end
