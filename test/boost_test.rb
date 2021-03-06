require_relative "test_helper"

class TestBoost < Minitest::Test

  # conversions

  def test_conversions
    store [
      {name: "Tomato A", conversions: {"tomato" => 1}},
      {name: "Tomato B", conversions: {"tomato" => 2}},
      {name: "Tomato C", conversions: {"tomato" => 3}}
    ]
    assert_order "tomato", ["Tomato C", "Tomato B", "Tomato A"]
  end

  def test_conversions_stemmed
    store [
      {name: "Tomato A", conversions: {"tomato" => 1, "tomatos" => 1, "Tomatoes" => 1}},
      {name: "Tomato B", conversions: {"tomato" => 2}}
    ]
    assert_order "tomato", ["Tomato A", "Tomato B"]
  end

  # global boost

  def test_boost
    store [
      {name: "Tomato A"},
      {name: "Tomato B", orders_count: 10},
      {name: "Tomato C", orders_count: 100}
    ]
    assert_order "tomato", ["Tomato C", "Tomato B", "Tomato A"], boost: "orders_count"
  end

  def test_boost_zero
    store [
      {name: "Zero Boost", orders_count: 0}
    ]
    assert_order "zero", ["Zero Boost"], boost: "orders_count"
  end

  def test_conversions_weight
    store [
      {name: "Product Boost", orders_count: 20},
      {name: "Product Conversions", conversions: {"product" => 10}}
    ]
    assert_order "product", ["Product Conversions", "Product Boost"], boost: "orders_count"
  end

  def test_user_id
    store [
      {name: "Tomato A"},
      {name: "Tomato B", user_ids: [1, 2, 3]},
      {name: "Tomato C"},
      {name: "Tomato D"}
    ]
    assert_first "tomato", "Tomato B", user_id: 2
  end

  def test_personalize
    store [
      {name: "Tomato A"},
      {name: "Tomato B", user_ids: [1, 2, 3]},
      {name: "Tomato C"},
      {name: "Tomato D"}
    ]
    assert_first "tomato", "Tomato B", personalize: {user_ids: 2}
  end

  def test_boost_fields
    store [
      {name: "Red", color: "White"},
      {name: "White", color: "Red Red Red"}
    ]
    assert_order "red", ["Red", "White"], fields: ["name^10", "color"]
  end

  def test_boost_fields_word_start
    store [
      {name: "Red", color: "White"},
      {name: "White", color: "Red Red Red"}
    ]
    assert_order "red", ["Red", "White"], fields: [{"name^10" => :word_start}, "color"]
  end

  def test_boost_by
    store [
      {name: "Tomato A"},
      {name: "Tomato B", orders_count: 10},
      {name: "Tomato C", orders_count: 100}
    ]
    assert_order "tomato", ["Tomato C", "Tomato B", "Tomato A"], boost_by: [:orders_count]
    assert_order "tomato", ["Tomato C", "Tomato B", "Tomato A"], boost_by: {orders_count: {factor: 10}}
  end

  def test_boost_where
    store [
      {name: "Tomato A"},
      {name: "Tomato B", user_ids: [1, 2, 3]},
      {name: "Tomato C"},
      {name: "Tomato D"}
    ]
    assert_first "tomato", "Tomato B", boost_where: {user_ids: 2}
    assert_first "tomato", "Tomato B", boost_where: {user_ids: {value: 2, factor: 10}}
  end

end
