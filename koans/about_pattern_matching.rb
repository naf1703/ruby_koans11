require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutPatternMatching < Neo::Koan

  def test_pattern_may_not_match
    begin
      case [true, false]
      in [a, b] if a == b
        :match
      end
    rescue Exception => ex
      assert_equal NoMatchingPatternError, ex.class
    end
  end

  def test_we_can_use_else
    result = case [true, false]
    in [a, b] if a == b
      :match
    else
     :no_match
    end

    assert_equal :no_match, result
  end

  # ------------------------------------------------------------------

  def value_pattern(variable)
    case variable
    in 0
      :match_exact_value
    in 1..10
      :match_in_range
    in Integer
      :match_with_class
    else
      :no_match
    end
  end

  def test_value_pattern
    assert_equal :match_exact_value, value_pattern(0)
    assert_equal :match_in_range, value_pattern(5)
    assert_equal :match_with_class, value_pattern(100)
    assert_equal :no_match, value_pattern('Not a Number!')
  end

  # ------------------------------------------------------------------

  def variable_pattern_with_binding(variable)
    case 0
    in variable
      variable
    else
      :no_match
    end
  end

  def test_variable_pattern_with_binding
    assert_equal 0, variable_pattern_with_binding(1)
  end

  # ------------------------------------------------------------------

  def variable_pattern_with_pin(variable)
    case 0
    in ^variable
      variable
    else
      :no_match
    end
  end

  def test_variable_pattern_with_pin
    assert_equal :no_match, variable_pattern_with_pin(1)
  end

  # ------------------------------------------------------------------

  def pattern_with_dropping(variable)
    case variable
    in [_, 2]
      :match
    else
      :no_match
    end
  end

  def test_pattern_with_dropping
    assert_equal :match, pattern_with_dropping(['I will not be checked', 2])
    assert_equal :no_match, pattern_with_dropping(['I will not be checked', 'But I will!'])
  end

  # ------------------------------------------------------------------

  def alternative_pattern(variable)
    case variable
    in 0 | false | nil
      :match
    else
      :no_match
    end
  end

  def test_alternative_pattern
    assert_equal :match, alternative_pattern(0)
    assert_equal :match, alternative_pattern(false)
    assert_equal :match, alternative_pattern(nil)
    assert_equal :no_match, alternative_pattern(4)
  end

  # ------------------------------------------------------------------

  def as_pattern
    a = 'First I was afraid'

    case 'I was petrified'
    in String => a
      a
    else
      :no_match
    end
  end

  def test_as_pattern
    assert_equal 'I was petrified', as_pattern
  end

  # ------------------------------------------------------------------

  class Deconstructible
    def initialize(str)
      @data = str
    end

    def deconstruct
      @data&.split('')
    end
  end

  def array_pattern(deconstructible)
    case deconstructible
    in 'a', *res, 'd'
      res
    else
      :no_match
    end
  end

  def test_array_pattern
    assert_equal ['b', 'c'], array_pattern(Deconstructible.new('abcd'))
    assert_equal :no_match, array_pattern(Deconstructible.new('123'))
  end

  # ------------------------------------------------------------------

  class LetterAccountant
    def initialize(str)
      @data = str
    end

    def deconstruct_keys(keys)
      keys.map { |key| [key, @data.count(key.to_s)] }.to_h
    end
  end

  def hash_pattern(deconstructible_as_hash)
    case deconstructible_as_hash
    in {a: a, b: b}
      [a, b]
    else
      :no_match
    end
  end

  def test_hash_pattern
    assert_equal [3, 2], hash_pattern(LetterAccountant.new('aaabbc'))
    assert_equal [0, 0], hash_pattern(LetterAccountant.new('xyz'))
  end

  def hash_pattern_with_sugar(deconstructible_as_hash)
    case deconstructible_as_hash
    in a:, b:
      [a, b]
    else
      :no_match
    end
  end

  def test_hash_pattern_with_sugar
    assert_equal [3, 2], hash_pattern_with_sugar(LetterAccountant.new('aaabbc'))
    assert_equal [0, 0], hash_pattern_with_sugar(LetterAccountant.new('xyz'))
  end

end