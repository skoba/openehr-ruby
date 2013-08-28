# ticket #176
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Constraint Refs' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.constraint_ref.test.adl')
    end

    it 'archetype is an instance of OpenEHR::AM::Archetype::Archetype' do
      @archetype.should be_an_instance_of OpenEHR::AM::Archetype::Archetype
    end
    context 'constraint ref node' do
      before(:all) do
        @cr = @archetype.definition.attributes[0].children[0].attributes[0].
          children[0].attributes[0].children[0].attributes[0].children[0]
      end
      it 'is an instance of ConstrantRef' do
        @cr.should be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::ConstraintRef
      end

      it 'path is /content[at0001]/items[at0002]/value/defining_code' do
        @cr.path.should == '/content[at0001]/items[at0002]/value/defining_code'
      end

      it 'reference is ac0001' do
        @cr.reference.should == 'ac0001'
      end
    end
  end
end
