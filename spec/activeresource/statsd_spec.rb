class Person < ActiveResource::Base
  self.site = "http://api.people.com"
end

RSpec.describe Activeresource::Statsd do
  it "has a version number" do
    expect(Activeresource::Statsd::VERSION).not_to be nil
  end

  describe "#init!" do
    let(:statsd) { double }

    before do
      described_class.init!(client: statsd)
    end

    after do
      described_class.reset!
    end

    it "record post requests" do
      stub_request(:any, "http://api.people.com/people.json")

      expected_tags = [
        "code:200",
        "response_type:2xx",
        "path:people-json",
        "method:post",
      ]

      expected_metric = "request.activeresource"
      expect(statsd).to receive(:measure).with(expected_metric,
          anything,
          tags: match_array(expected_tags))
      Person.new.save
    end

    it "records get requests" do
      stub_request(:any, "http://api.people.com/people/1.json").to_return(body: "{}")

      expected_tags = [
        "code:200",
        "response_type:2xx",
        "path:people-id-json",
        "method:get",
      ]

      expected_metric = "request.activeresource"
      expect(statsd).to receive(:measure).with(expected_metric,
          anything,
          tags: match_array(expected_tags))
      Person.find(1)
    end

    it "handles timeout errors" do
      stub_request(:any, "http://api.people.com/people.json").to_timeout

      expected_tags = [
        "path:people-json",
        "method:post",
        "error:net-opentimeout",
      ]

      expected_metric = "request.activeresource"
      expect(statsd).to receive(:measure).with(expected_metric,
          anything,
          tags: match_array(expected_tags))

      begin
        Person.new.save
      rescue ActiveResource::TimeoutError
      end
    end
  end
end
