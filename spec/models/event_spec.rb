require "rails_helper"
RSpec.describe Event do
  describe ".with_open_ticket_sale" do
    it "returns events that have not started yet" do
      event = create(:event, starts_on: Time.zone.tomorrow)
      expect(described_class.with_open_ticket_sale).to include(event)
    end

    # rubocop: disable Rails/SkipsModelValidations
    it "does not return events that have already started" do
      event = create(:event).tap { |e| e.update_attribute(:starts_on, Time.zone.yesterday) }
      expect(described_class.with_open_ticket_sale).not_to include(event)
    end
    # rubocop: enable Rails/SkipsModelValidations
  end

  describe "#title" do
    it "is required" do
      event = build(:event, title: nil)
      event.valid?
      expect(event.errors.messages[:title]).to include("can't be blank")
    end
  end

  describe "#price" do
    it "is required" do
      event = build(:event, price: nil)
      event.valid?
      expect(event.errors.messages[:price]).to include("can't be blank")
    end
  end

  describe "#location" do
    it "is required" do
      event = build(:event, location: nil)
      event.valid?
      expect(event.errors.messages[:location]).to include("can't be blank")
    end
  end

  describe "#starts_on" do
    it "is required" do
      event = build(:event, starts_on: nil)
      event.valid?
      expect(event.errors.messages[:starts_on]).to include("can't be blank")
    end

    it "is in the future" do
      event = build(:event, starts_on: Date.yesterday)
      event.valid?
      expect(event.errors.messages[:starts_on]).to include("must be in the future")
    end
  end

  describe "#ends_on" do
    it "is required" do
      event = build(:event, ends_on: nil)
      event.valid?
      expect(event.errors.messages[:ends_on]).to include("can't be blank")
    end

    it "is after the starts_on date" do
      event = build(:event, starts_on: Time.zone.today, ends_on: Date.yesterday)
      event.valid?
      expect(event.errors.messages[:ends_on]).to include("must be after the starts_on date")
    end
  end

  describe "#capacity" do
    it "is required" do
      event = build(:event, capacity: nil)
      event.valid?
      expect(event.errors.messages[:capacity]).to include("can't be blank")
    end

    it "is greater than 0" do
      event = build(:event, capacity: 0)
      event.valid?
      expect(event.errors.messages[:capacity]).to include("must be greater than 0")
    end
  end

  describe "#ticket_sale" do
    it "is initialized after initialization" do
      event = described_class.new
      expect(event.ticket_sale).to be_present
    end

    it "is required" do
      event = build(:event)
      event.ticket_sale = nil
      event.valid?
      expect(event.errors.messages[:ticket_sale]).to include("can't be blank")
    end

    it "is saved together with the event" do
      event = described_class.create(attributes_for(:event))
      expect(event.ticket_sale).to be_persisted
    end
  end
end
