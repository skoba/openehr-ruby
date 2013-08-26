# -*- coding: utf-8 -*-
# ticket 190
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Unicode support spec' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.unicode_support.test.adl')
    end

    it 'is an instance of Archetype' do
      @archetype.should be_an_instance_of OpenEHR::AM::Archetype::Archetype
    end

    context 'parsing Chineze' do
      before(:all) do
        @chineze_term = @archetype.ontology.term_definition(lang: 'zh',
                                                           code: 'at0000')
      end

      it 'text is 概念' do
        @chineze_term.items['text'].should == "概念"
      end

      it 'description is 描述' do
        @chineze_term.items['description'].should == "描述"
      end
    end

    context 'parsing Swedish' do
      before(:all) do
        @swedish_term = @archetype.ontology.term_definition(lang: 'sv',
                                                            code: 'at0000')
      end

      it 'text is språk' do
        @swedish_term.items['text'].should == "språk"
      end

      it 'description is Hj\u00e4lp' do
        @swedish_term.items['description'].should == "Hjälp"
      end
    end
  end
end
