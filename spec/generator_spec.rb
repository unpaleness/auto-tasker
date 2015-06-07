require 'spec_helper'
require 'generator'

module AutoTasker

  describe Generator do
    let(:common_exec) { "spec/test_path_to_exec/exec.sh" }
    let(:common_config) { "spec/test_path_to_config/test_config_fake.yml" }
    let(:common_test) { "true" }
    let(:common_local) { "true" }
    let(:current_dir) { (`pwd`).delete!("\n") }

    context "testing variables:" do
      let(:executable) { (`pwd` + "/#{common_exec}").delete!("\n") }
      let(:config) { (`pwd` + "/#{common_config}").delete!("\n") }
      let(:ranges) { {"name"=>"test_fake_config","args"=>"10 20 30 0.1 xyz"} }
      subject { Generator.new(common_exec, common_config, common_test, common_local) }
      it "\@test" do
        expect(subject.test).to eq common_test
      end
      it "\@local" do
        expect(subject.local).to eq common_local
      end
      it "\@executable" do
        expect(subject.executable).to eq executable
      end
      it "\@config" do
        expect(subject.config).to eq config
      end
      it "\@current_dir" do
        expect(subject.current_dir).to eq current_dir
      end
      it "\@ranges" do
        expect(subject.ranges).to eq ranges
      end
    end

    context "testing sequences:" do
      let(:config) { "spec/test_path_to_config/test_config_1.yml" }
      let(:dirs) do
        [
          "#{current_dir}/tasks/vde-test_sequence-p@S1@A-1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S1@A-3-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S1@A-5-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S1@A-7-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S1@A-9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S2@B-1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S2@B-3-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S2@B-5-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S2@B-7-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S2@B-9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S3@C-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S3@C-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S4@A-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S4@A-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S5@B-43-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@S5@B-98-10x10-20s-0.1-xyz"
        ]
      end
      subject { Generator.new(common_exec, config, common_test, common_local) }
      it "generate" do
        subject.generate
        expect(subject.dirs).to eq dirs
      end
    end

    context "testing nesting:" do
      let(:config) { "spec/test_path_to_config/test_config_2.yml" }
      let(:dirs) do
        [
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-1-p@S2@B-2-p@S3@C-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-1-p@S2@B-2-p@S3@C-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-1-p@S2@B-3-p@S3@C-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-1-p@S2@B-3-p@S3@C-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-1-p@S4@A-1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-1-p@S4@A-5-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-10-p@S2@B-2-p@S3@C-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-10-p@S2@B-2-p@S3@C-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-10-p@S2@B-3-p@S3@C-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-10-p@S2@B-3-p@S3@C-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-10-p@S4@A-1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@S1@A-10-p@S4@A-5-10x10-20s-0.1-xyz"
        ]
      end
      subject { Generator.new(common_exec, config, common_test, common_local) }
      it "generate" do
        subject.generate
        expect(subject.dirs).to eq dirs
      end
    end
  end

end
