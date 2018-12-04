require 'gooddata'
require 'json'
params = JSON.parse(File.read('.\info_login\user_pass.txt'))
client = GoodData.connect(params)

# Create model with blueprint
blueprint = GoodData::Model::ProjectBlueprint.build("my_blueprint") do |p|
    p.add_dataset('dataset.person', title: 'Person') do |d|
      d.add_anchor('attr.person.id', title: 'Person ID')
      d.add_label('label.person.id', reference: 'attr.person.id')
      d.add_attribute('attr.person.name', title: 'Person Name')
      d.add_label('label.person.name', reference: 'attr.person.name')
	  d.add_fact('fact.age', title: 'Person Age', folder: 'Person Folder')
    end

    p.add_dataset('dataset.department', title: 'Department') do |d|
      d.add_anchor('attr.department.id', title: 'Department ID')
      d.add_label('label.department.id', reference: 'attr.department.id')
      d.add_attribute('attr.department.name', title: 'Department Name')
      d.add_label('label.department.name', reference: 'attr.department.name')
    end
  
    p.add_dataset('dataset.opportunities', title: 'Opportunities') do |d|
      d.add_anchor('attr.opportunities.id', title: 'Opportunities ID')
      d.add_label('label.opportunities.id', reference: 'attr.opportunities.id')
      d.add_fact('fact.amount', title: 'Opportunities Amount', folder: 'Opportunities Folder')
      d.add_reference('dataset.person')
      d.add_reference('dataset.department')
	end
end

# Create project with model above
project = client.create_project_from_blueprint( blueprint, 
												title: 'Tien Test RubySDK 01', 
												auth_token: 'pgstg2')
puts '=> Project ' + '"'  + project.title + '"' + ' with uri: ' + project.uri + ' created successfully!'

# Invite user into project is created above
project.invite('bktien+2@lhv.vn', 'admin', 'Hey Tien, look at this.')
puts '=> User "bktien+2@lhv.vn" is invited into project ' + project.title + ' successfully!'

# Upload data into project
data =[
  ['label.person.id','label.person.name','fact.age'],
  ['101','Tien 01',21],
  ['102','Tien 02',22],
  ['103','Tien 03',23],
  ['104','Tien 04',24],
  ['105','Tien 05',25]]
project.upload(data, blueprint, 'dataset.person')

data =[
  ['label.department.id','label.department.name'],
  ['D01','Department 01'],
  ['D02','Department 02'],
  ['D03','Department 03'],
  ['D04','Department 04'],
  ['D05','Department 05']]
project.upload(data, blueprint, 'dataset.department')

data =[
  ['label.opportunities.id','fact.amount','dataset.person','dataset.department'],
  ['Oppo 01',21,'101','D01'],
  ['Oppo 02',22,'102','D01'],
  ['Oppo 03',23,'103','D02'],
  ['Oppo 04',24,'104','D03'],
  ['Oppo 05',25,'105','D04'],
  ['Oppo 06',26,'104','D05'],
  ['Oppo 07',27,'105','D05']]
project.upload(data, blueprint, 'dataset.opportunities')
puts '=> Upload data into project ' + project.title + ' successfully!'

# Create metric
metric_amount_sum = project.add_measure 'SELECT SUM(![fact.amount])',
     title: 'SUM Amount'
    metric_amount_sum.save
    metric_amount_sum.execute
puts '=> Metric ' + '"' + metric_amount_sum.title + '"' + 'created successfully!'

metric_age_sum = project.add_measure 'SELECT SUM(![fact.age])',
     title: 'SUM Age'
    metric_age_sum.save
    metric_age_sum.execute
puts '=> Metric ' + '"' + metric_age_sum.title + '"' + 'created successfully!' 

# Create report with filter
label_person_id = project.labels('label.person.id')
report = project.create_report( title: 'Tien report 01', 
                                top: [metric_amount_sum], 
                                left: [
                                  'label.person.id',
                                  'label.person.name',
                                  'label.department.id',
                                  'label.department.name',
                                  'label.opportunities.id'],
                                filters:[[label_person_id, '101', '102', '103']])
puts '=> Report ' + '"' + report.title + '"' '+ with uri: ' + report.uri + ' created successfully!'




# Clone project
=begin
project = client.projects(project_id)
cloned_project = project.clone(title: 'Project is cloned by Tien Test RubySDK 01',
                               auth_token: 'pgstg2',
                               users: false,
                               data: true,
                               exclude_schedules: true,
                               cross_data_center_export: true)
=end
