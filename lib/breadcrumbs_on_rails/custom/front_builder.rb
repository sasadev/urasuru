module BreadcrumbsOnRails
  module Custom
    class FrontBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
      def render
        @context.render "/front/breadcrumbs", elements: @elements
      end
    end
  end
end