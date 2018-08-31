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
      stub_request(:any, "http://api.people.com/people.json")
      stub_request(:any, "http://api.people.com/people/1.json").to_return(body: "{}")
      described_class.init!(client: statsd)
    end

    after do
      described_class.reset!
    end

    it "record post requests" do
      expected_tags = [
        "code:200",
        "response_type:2xx",
        "path:people.json",
        "method:post",
      ]

      expected_metric = "request.activeresource"
      expect(statsd).to receive(:measure).with(expected_metric,
          anything,
          tags: expected_tags)
      Person.new.save
    end

    it "records get requests" do
      expected_tags = [
        "code:200",
        "response_type:2xx",
        "path:people-id.json",
        "method:get",
      ]

      expected_metric = "request.activeresource"
      expect(statsd).to receive(:measure).with(expected_metric,
          anything,
          tags: expected_tags)
      Person.find(1)
    end
  end
end
