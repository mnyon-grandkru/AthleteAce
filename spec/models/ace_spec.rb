require 'rails_helper'

RSpec.describe Ace, type: :model do
  # Associations
  describe 'associations' do
    it { should have_many(:goals).dependent(:destroy) }
    it { should have_many(:active_goals).class_name('Goal') }
    it { should have_many(:quests).through(:goals) }
    it { should have_many(:ratings).dependent(:destroy) }
    it { should have_many(:game_attempts).dependent(:destroy) }
  end

  # Factory
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:ace)).to be_valid
    end

    it 'has a valid factory with goals' do
      ace = create(:ace, :with_goals, goals_count: 3)
      expect(ace.goals.count).to eq(3)
      expect(ace.quests.count).to eq(3)
    end
  end

  # Methods
  describe '#adopt_quest' do
    let(:ace) { create(:ace) }
    let(:quest) { create(:quest) }

    context 'when quest is not already adopted' do
      it 'creates a new goal' do
        expect {
          ace.adopt_quest(quest)
        }.to change(Goal, :count).by(1)
      end

      it 'associates the goal with the quest' do
        goal = ace.adopt_quest(quest)
        expect(goal.quest).to eq(quest)
      end
    end

    context 'when quest is already adopted' do
      before do
        create(:goal, ace: ace, quest: quest)
      end

      it 'does not create a new goal' do
        expect {
          ace.adopt_quest(quest)
        }.not_to change(Goal, :count)
      end

      it 'returns the existing goal' do
        existing_goal = ace.goals.find_by(quest: quest)
        expect(ace.adopt_quest(quest)).to eq(existing_goal)
      end
    end

    context 'with invalid quest' do
      it 'raises an error' do
        expect {
          ace.adopt_quest(nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#abandon_quest' do
    let(:ace) { create(:ace) }
    let(:quest) { create(:quest) }

    context 'when quest is adopted' do
      before do
        create(:goal, ace: ace, quest: quest)
      end

      it 'destroys the associated goals' do
        expect {
          ace.abandon_quest(quest)
        }.to change(Goal, :count).by(-1)
      end

      it 'removes the quest association' do
        ace.abandon_quest(quest)
        expect(ace.quests).not_to include(quest)
      end
    end

    context 'when quest is not adopted' do
      it 'does not raise an error' do
        expect {
          ace.abandon_quest(quest)
        }.not_to raise_error
      end

      it 'does not change goal count' do
        expect {
          ace.abandon_quest(quest)
        }.not_to change(Goal, :count)
      end
    end
  end

  describe '#rate' do
    let(:ace) { create(:ace) }
    let(:target) { create(:player) }
    let(:spectrum) { create(:spectrum) }

    context 'with valid parameters' do
      let(:value) { 5000 }
      let(:notes) { 'Great performance!' }

      it 'creates a new rating' do
        expect {
          ace.rate(target, spectrum, value, notes)
        }.to change(Rating, :count).by(1)
      end

      it 'sets the correct attributes' do
        rating = ace.rate(target, spectrum, value, notes)
        expect(rating.value).to eq(value)
        expect(rating.notes).to eq(notes)
        expect(rating.target).to eq(target)
        expect(rating.spectrum).to eq(spectrum)
      end

      context 'when rating already exists' do
        before do
          create(:rating, ace: ace, target: target, spectrum: spectrum, value: 1000)
        end

        it 'updates the existing rating' do
          expect {
            ace.rate(target, spectrum, value, notes)
          }.not_to change(Rating, :count)
        end

        it 'updates the value' do
          rating = ace.rate(target, spectrum, value, notes)
          expect(rating.value).to eq(value)
        end
      end
    end

    context 'with invalid parameters' do
      it 'raises error with nil target' do
        expect {
          ace.rate(nil, spectrum, 5000)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'raises error with nil spectrum' do
        expect {
          ace.rate(target, nil, 5000)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'raises error with invalid value' do
        expect {
          ace.rate(target, spectrum, 15000)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#ratings_for' do
    let(:ace) { create(:ace) }
    let(:target) { create(:player) }
    let!(:active_rating) { create(:rating, ace: ace, target: target, archived: false) }
    let!(:archived_rating) { create(:rating, ace: ace, target: target, archived: true) }

    it 'returns only active ratings for the target' do
      expect(ace.ratings_for(target)).to include(active_rating)
      expect(ace.ratings_for(target)).not_to include(archived_rating)
    end

    it 'returns empty relation for non-existent target' do
      expect(ace.ratings_for(create(:player))).to be_empty
    end
  end

  describe '#rating_for' do
    let(:ace) { create(:ace) }
    let(:target) { create(:player) }
    let(:spectrum) { create(:spectrum) }
    let!(:rating) { create(:rating, ace: ace, target: target, spectrum: spectrum, archived: false) }

    it 'returns the rating for the target and spectrum' do
      expect(ace.rating_for(target, spectrum)).to eq(rating)
    end

    it 'returns nil for non-existent rating' do
      expect(ace.rating_for(target, create(:spectrum))).to be_nil
    end

    it 'returns nil for archived rating' do
      rating.update!(archived: true)
      expect(ace.rating_for(target, spectrum)).to be_nil
    end
  end

  describe '#rated?' do
    let(:ace) { create(:ace) }
    let(:target) { create(:player) }
    let(:spectrum) { create(:spectrum) }

    context 'when rating exists' do
      before do
        create(:rating, ace: ace, target: target, spectrum: spectrum)
      end

      it 'returns true' do
        expect(ace.rated?(target, spectrum)).to be true
      end
    end

    context 'when rating does not exist' do
      it 'returns false' do
        expect(ace.rated?(target, spectrum)).to be false
      end
    end

    context 'when rating is archived' do
      before do
        create(:rating, ace: ace, target: target, spectrum: spectrum, archived: true)
      end

      it 'returns true' do
        expect(ace.rated?(target, spectrum)).to be true
      end
    end
  end
end
