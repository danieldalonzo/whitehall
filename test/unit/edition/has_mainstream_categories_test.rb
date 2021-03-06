require "test_helper"

class Edition::HasMainstreamCategoriesTest < ActiveSupport::TestCase
  test "#mainstream_categories returns an array containing all associated mainstream categories" do
    primary_mainstream_category = create(:mainstream_category)
    other_mainstream_category = create(:mainstream_category)
    edition = create(:draft_detailed_guide,
                     primary_mainstream_category: primary_mainstream_category,
                     other_mainstream_categories: [other_mainstream_category])

    assert_equal [primary_mainstream_category, other_mainstream_category],
                 edition.mainstream_categories
  end

  test "edition should be invalid with the same category in primary and other" do
    mainstream_category = create(:mainstream_category)
    edition = build(:draft_detailed_guide, primary_mainstream_category: mainstream_category,
                     other_mainstream_categories: [mainstream_category])

    refute edition.valid?
    assert edition.errors[:other_mainstream_categories].include?("should not contain the primary mainstream category")
  end

  test "edition should be invalid with other categories and no primary category" do
    category = create(:mainstream_category)
    edition = build(:draft_detailed_guide, primary_mainstream_category: nil,
                                           other_mainstream_categories: [category])

    refute edition.valid?
  end

  test "#destroy should also remove the relationship" do
    mainstream_category = create(:mainstream_category)
    edition = create(:draft_detailed_guide, other_mainstream_categories: [mainstream_category])
    relation = edition.edition_mainstream_categories.first
    edition.destroy
    refute EditionMainstreamCategory.find_by(id: relation.id)
  end

  test "can be dissociated from a mainstream category e.g. if we delete the category" do
    primary_mainstream_category = create(:mainstream_category)
    other_mainstream_category = create(:mainstream_category)
    published_guide = create(:published_detailed_guide,
                             primary_mainstream_category: primary_mainstream_category,
                             other_mainstream_categories: [other_mainstream_category])


    published_guide.remove_mainstream_category!(primary_mainstream_category)
    published_guide.remove_mainstream_category!(other_mainstream_category)

    assert_nil published_guide.primary_mainstream_category_id
    assert published_guide.other_mainstream_category_ids.empty?

  end
end
