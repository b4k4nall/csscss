require "test_helper"

module Csscss
  describe Reporter do
    include TypeHelpers

    it "formats string result" do
      reporter = Reporter.new({
        [sel(".foo"), sel(".bar")] => [dec("width", "1px"), dec("border", "black")],
        [sel("h1, h2"), sel(".foo"), sel(".baz")] => [dec("display", "none")],
        [sel("h1, h2"), sel(".bar")] => [dec("position", "relative")]
      })

     expected =<<-EXPECTED
{.foo} AND {.bar} share 2 rules
{h1, h2}, {.foo} AND {.baz} share 1 rule
{h1, h2} AND {.bar} share 1 rule
EXPECTED
     reporter.report(color:false).must_equal expected

     expected =<<-EXPECTED
{.foo} AND {.bar} share 2 rules
  - width: 1px
  - border: black
{h1, h2}, {.foo} AND {.baz} share 1 rule
  - display: none
{h1, h2} AND {.bar} share 1 rule
  - position: relative
EXPECTED
     reporter.report(verbose:true, color:false).must_equal expected
    end

    it "prints the regular results and the specific duplicates when dulicates are given" do
      reporter = Reporter.new({
        [sel(".foo"), sel(".bar")] => [dec("width", "1px"), dec("border", "black")]
      })

      expected =<<-EXPECTED
{.foo} AND {.bar} share 2 rules
[foo AND bar] are identical selectors that share 2 attributes
      EXPECTED
      reporter.report(color:false, duplicates: [['foo', 'bar', %w('attribute', 'other_attribute')]]).must_equal expected
    end

    it "prints the regular results and the subsets when subsets are given" do
      reporter = Reporter.new({
        [sel(".foo"), sel(".bar")] => [dec("width", "1px"), dec("border", "black")]
                              })

      expected =<<-EXPECTED
{.foo} AND {.bar} share 2 rules
[foo(2 attributes) is a subset of the following classes: bar]
      EXPECTED
      reporter.report(color:false, subsets: [['foo', ['bar'], %w('attribute', 'other_attribute')]]).must_equal expected
    end

    it "prints a new line if there is nothing" do
      reporter = Reporter.new({})
      reporter.report().must_equal ""
    end
  end
end
