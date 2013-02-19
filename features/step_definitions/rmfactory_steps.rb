Given /^\"DV_TEXT\" in archetype definition with attribute$/ do
  @type= "DV_TEXT"
  @params = [value: 'text']
end

When /^RM Factory generates instance$/ do
  @dv_text = OpenEHR::RM::Factory.create(@type, @params)
end

Then /^DvText instance should be available$/ do
  @dv_text.should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText
end
