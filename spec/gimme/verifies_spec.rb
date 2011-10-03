require 'spec_helper'

describe Gimme::Verifies do
  class Natto
    def ferment(beans=nil,time=nil)
    end
  end
  Given(:double) { gimme(Natto) }

  shared_examples_for "a verifier" do

    context "invoked once when expected once" do
      Given { double.ferment }
      When(:result) { lambda { verifier.ferment } }
      Then { result.should_not raise_error }
    end

    context "never invoked" do
      When(:result) { lambda { verifier.ferment } }
      Then { result.should raise_error Errors::VerificationFailedError }
    end

    context "invoked with incorrect args" do
      Given { double.ferment(5) }
      When(:result) { lambda { verifier.ferment(4) } }
      Then { result.should raise_error Errors::VerificationFailedError }
    end

    context "invoked too few times" do
      Given(:verifier) { Verifies.new(double,3) }
      Given { 2.times { double.ferment } }
      When(:result) { lambda { verifier.ferment } }
      Then { result.should raise_error Errors::VerificationFailedError }
    end

    context "juggling multiple verifiers for the same method" do
      Given(:multi_verifier) { Verifies.new(double,2) }
      Given { double.ferment(:panda,:sauce) }
      Given { 2.times { double.ferment(2,3) } }
      When(:result) do
        lambda do
          multi_verifier.ferment(2,3)
          verifier.ferment(:panda,:sauce)
        end
      end
      Then { result.should_not raise_error }
    end

    context "a method not on the double" do
      When(:result) { lambda { verifier.eat } }
      Then { result.should raise_error NoMethodError }
    end
  end

  shared_examples_for "an overridden verifier" do
    context "a method not on the double that is invoked" do
      Given { double.eat }
      When(:result) { lambda { verifier.eat } }
      Then { result.should_not raise_error }
    end

    context "a method not on the double that is _not_ invoked" do
      When(:result) { lambda { verifier.eat } }
      Then { result.should raise_error Errors::VerificationFailedError }
    end
  end

  context "class API" do
    Given(:verifier) { Verifies.new(double) }
    it_behaves_like "a verifier"
    it_behaves_like "an overridden verifier" do
      Given { verifier.raises_no_method_error = false }
    end
  end

  context "gimme DSL" do
    it_behaves_like "a verifier" do
      Given(:verifier) { verify(double) }
    end

    it_behaves_like "an overridden verifier" do
      Given(:verifier) { verify!(double) }
    end
  end

end