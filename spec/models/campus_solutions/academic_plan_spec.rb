describe CampusSolutions::AcademicPlan do

  let(:user_id) { random_id }
  let(:user_cs_id) { random_id }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the enrollment card flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:updateAcademicPlanner]).to be
    end
  end

  context 'mock proxy' do
    before do
      allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: user_id).and_return(
        double(lookup_campus_solutions_id: user_cs_id))
    end
    let(:proxy) { CampusSolutions::AcademicPlan.new(fake: true, user_id: user_id, term_id: '2176') }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'
    it 'includes specific mock data' do
      expect(subject[:feed][:studentId]).to eq '24437121'
      expect(subject[:feed][:updateAcademicPlanner][:url]).to eq 'https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/SCI_PLNR_FL.SCI_PLNR_FL.GBL?ucInstitution=UCB01'
    end
  end
end
