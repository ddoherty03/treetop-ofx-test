# frozen_string_literal: true

module OfxGrammer
  class Node < Treetop::Runtime::SyntaxNode
    def name
      elements[0].text_value.delete_prefix('<').delete_suffix('>')
    end

    def sym
      name.tr('.', '_').downcase.to_sym
    end
  end

  class Children < Node
  end

  class Tag < Node
  end

  class Value < Node
  end

  class Aggregate < Node
    def val
      to_hash
    end

    def kids
      elements[1].elements
    end

    # NOTE: this returns the whole response as a hash without an outer hash
    # for the always-present OFX aggregate.  Elements that are aggregates
    # are enclosed in an Array so multiple instances are recorded.
    def to_hash
      hash = {}
      kids.each do |kid|
        val = kid.to_hash
        if val.is_a?(Hash)
          hash[kid.sym] ||= []
          hash[kid.sym] << val
        else
          hash[kid.sym] = val
        end
      end
      hash
    end
  end

  class Field < Node
    # Return the value cast to the correct Ruby type depending on the key
    # sym.
    def val
      value = HTMLEntities.new.decode(elements[1].text_value.strip)
      case sym.to_s
      when /\Adt/, /time\z/
        DateTime.parse(value)
      when /(amt|fee|price)\z/,
        /\A(yield|gain|fee)/,
        /(couponrt|percent|accrdint|avgcostbasis|commission)/,
        /(numerator|denominator|fraccash|load|markdown|markup)/,
        /(newunits|oldunits|shperctrct|total|taxes)/,
        /(units|unittype|withholding|minunits|limitprice|stopprice)/,
        /(unitsstreet|unitsuser|availcash|marginbalance|bal)/
        if /\A[-+\d.]+\z/.match?(value)
          BigDecimal(value.bdv)
        else
          value
        end
      else
        value
      end
    rescue Date::Error => e
      if /invalid date/.match?(e.to_s)
        Byr.handle_logic_error("'#{value}' cannot be parsed as a valid date", e)
      end
      raise e
    end

    def to_hash
      val
    end
  end
end
