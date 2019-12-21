RSpec.describe AllCompanies do
  it "has a version number" do
    expect(AllCompanies::VERSION).not_to be nil
  end

  it "can return a collection of companies" do
    companies = AllCompanies::Finder.find

    expect(companies.first.class).to eq(Company)
  end
end
