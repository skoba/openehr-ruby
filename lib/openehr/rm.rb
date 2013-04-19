#Support Informational Model
require_relative 'assumed_library_types'
require_relative 'rm/support/definition'
require_relative 'rm/support/identification'
require_relative 'rm/support/measurement'

#Data Types Informational Model
require_relative 'rm/data_types/basic'
require_relative 'rm/data_types/text'
require_relative 'rm/data_types/quantity'
require_relative 'rm/data_types/quantity/date_time'
require_relative 'rm/data_types/encapsulated'
require_relative 'rm/data_types/time_specification'
require_relative 'rm/data_types/uri'

#Data Structures Informational Model
require_relative 'rm/data_structures'
require_relative 'rm/data_structures/item_structure'
require_relative 'rm/data_structures/item_structure/representation'
require_relative 'rm/data_structures/history'

#Common Information Model
require_relative 'rm/common/archetyped'
require_relative 'rm/common/generic'
require_relative 'rm/common/change_control'
require_relative 'rm/common/directory'
require_relative 'rm/common/resource'

#Security Information Model
require_relative 'rm/security'

#EHR Information Model
require_relative 'rm/composition'
require_relative 'rm/composition/content'
require_relative 'rm/composition/content/navigation'
require_relative 'rm/composition/content/entry'
require_relative 'rm/ehr'

#Demographic Information Model
require_relative 'rm/demographic'

#Integration Information Model
require_relative 'rm/integration'


require_relative 'rm/factory'

