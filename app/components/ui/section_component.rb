class UI::SectionComponent < ViewComponent::Base
  DEFAULT_OUTER_CLASSES = "py-20".freeze
  DEFAULT_INNER_CLASSES = "container".freeze

  BACKGROUND_COLORS = {
    none: "",
    light: "bg-base-200",
    dark: "bg-base-300",
    primary: "bg-primary text-primary-content"
  }.freeze

  # @param bg [Symbol, String] background color preset (:none, :light, :dark, :primary) or custom classes
  # @param py [String, nil] vertical padding override (default: "py-20")
  # @param class_name [String, nil] extra classes for the outer section wrapper
  # @param inner_class [String, nil] extra classes for the inner container
  # @param outer_class [String, nil] full override for outer classes (use sparingly)
  # @param tag [Symbol] wrapper tag for the outer container (default: :section)
  # @param kwargs [Hash] any extra HTML attributes for the outer container (id, data, aria, etc.)
  def initialize(bg: :none, py: nil, class_name: nil, inner_class: nil, outer_class: nil, tag: :section, **kwargs)
    @bg = bg
    @py = py
    @class_name = class_name
    @inner_class = inner_class
    @outer_class = outer_class
    @tag = tag
    @kwargs = kwargs
  end

  private

  attr_reader :bg, :py, :class_name, :inner_class, :outer_class, :tag, :kwargs

  def outer_classes
    if outer_class.present?
      outer_class
    else
      [
        background_classes,
        py || DEFAULT_OUTER_CLASSES,
        class_name
      ].compact.join(" ")
    end
  end

  def inner_classes
    [ DEFAULT_INNER_CLASSES, inner_class ].compact.join(" ")
  end

  def background_classes
    if bg.is_a?(Symbol)
      BACKGROUND_COLORS[bg]
    else
      bg.to_s
    end
  end
end
