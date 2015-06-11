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
          "#{current_dir}/tasks/vde-test_sequence-p@s1@a-1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s1@a-3-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s1@a-5-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s1@a-7-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s1@a-9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s2@b--2-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s2@b-0-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s2@b-2-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s2@b-4-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s2@b-6-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s3@c-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s3@c-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s4@a-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s4@a-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s5@b-43-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s5@b-98-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s6@c--200000.0-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_sequence-p@s6@c--100000.0-10x10-20s-0.1-xyz"
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
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-1-p@s2@b-2-p@s3@c-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-1-p@s2@b-2-p@s3@c-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-1-p@s2@b-3-p@s3@c-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-1-p@s2@b-3-p@s3@c-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-1-p@s4@a-1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-1-p@s4@a-5-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-10-p@s2@b-2-p@s3@c-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-10-p@s2@b-2-p@s3@c-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-10-p@s2@b-3-p@s3@c-1e1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-10-p@s2@b-3-p@s3@c-1e9-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-10-p@s4@a-1-10x10-20s-0.1-xyz",
          "#{current_dir}/tasks/vde-test_nesting-p@s1@a-10-p@s4@a-5-10x10-20s-0.1-xyz"
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
