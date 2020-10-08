require 'rails_helper'

describe CommonwealthVlrEngine::SearchHistoryConstraintsHelperBehavior do
  let(:fake_controller) { CatalogController.new }

  before(:each) do
    fake_controller.extend(CommonwealthVlrEngine::SearchHistoryConstraintsHelperBehavior)
    fake_controller.extend(CommonwealthVlrEngine::ApplicationHelper)
  end

  describe 'render_search_to_s_mlt' do
    let (:mlt_test_params) { {mlt_id: 'bpl-dev:h702q6403'} }

    it 'returns render_search_to_s_element when mlt params are present' do
      expect(fake_controller).to receive(:render_search_to_s_element)
      expect(fake_controller).to receive(:render_filter_value)
      fake_controller.render_search_to_s_mlt(mlt_test_params)
    end
  end

  describe 'render_search_to_s_advanced' do
    let (:date_range_params) { {date_start: '1970', date_end: '2000'} }

    it 'returns render_search_to_s_element when date range params are present' do
      expect(fake_controller).to receive(:render_search_to_s_element)
      expect(fake_controller).to receive(:render_filter_value)
      fake_controller.render_search_to_s_advanced(date_range_params)
    end
  end
end
