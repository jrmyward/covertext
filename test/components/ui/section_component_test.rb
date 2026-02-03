require "test_helper"

class UI::SectionComponentTest < ViewComponent::TestCase
  test "renders default outer and inner classes" do
    render_inline(UI::SectionComponent.new) { "Hello" }

    assert_selector "section.py-20"
    assert_selector "section div.container", text: "Hello"
  end

  test "renders with background preset :light" do
    render_inline(UI::SectionComponent.new(bg: :light)) { "Hello" }

    assert_selector "section.bg-base-200.py-20"
  end

  test "renders with background preset :dark" do
    render_inline(UI::SectionComponent.new(bg: :dark)) { "Hello" }

    assert_selector "section.bg-base-300.py-20"
  end

  test "renders with background preset :primary" do
    render_inline(UI::SectionComponent.new(bg: :primary)) { "Hello" }

    assert_selector "section.bg-primary.text-primary-content.py-20"
  end

  test "renders with custom background string" do
    render_inline(UI::SectionComponent.new(bg: "bg-gradient-to-br from-primary/10")) { "Hello" }

    assert_selector "section.bg-gradient-to-br.from-primary\\/10"
  end

  test "overrides vertical padding" do
    render_inline(UI::SectionComponent.new(py: "py-10")) { "Hello" }

    assert_selector "section.py-10"
    assert_no_selector "section.py-20"
  end

  test "appends extra classes to outer and inner" do
    render_inline(UI::SectionComponent.new(class_name: "mt-4", inner_class: "max-w-4xl")) { "Hello" }

    assert_selector "section.py-20.mt-4"
    assert_selector "section div.container.max-w-4xl"
  end

  test "outer_class fully overrides defaults" do
    render_inline(UI::SectionComponent.new(outer_class: "custom-section")) { "Hello" }

    assert_selector "section.custom-section"
    assert_no_selector "section.py-20"
  end

  test "renders with custom tag" do
    render_inline(UI::SectionComponent.new(tag: :div)) { "Hello" }

    assert_selector "div.py-20"
    assert_selector "div div.container", text: "Hello"
  end

  test "passes through html attributes" do
    render_inline(UI::SectionComponent.new(id: "pricing", data: { section: "main" })) { "Hello" }

    assert_selector 'section#pricing[data-section="main"]'
  end
end
