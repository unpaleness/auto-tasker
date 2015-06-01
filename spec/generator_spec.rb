require 'spec_helper'
require 'generator'

module AutoTasker

  describe Generator do
    let(:common_exec) { "spec/test_path_to_exec/exec" }
    let(:common_config) { "spec/test_path_to_config/test_config_fake.yml" }
    let(:common_test) { "true" }

    context "testing variables:"do
      let(:executable) { (`pwd` + "/#{common_exec}").delete!("\n") }
      let(:config) { (`pwd` + "/#{common_config}").delete!("\n") }
      let(:current_dir) { (`pwd`).delete!("\n") }
      let(:ranges) { {"name"=>"test_fake_config"} }
      subject { Generator.new(common_exec, common_config, "true") }
      it "\@test" do
        expect(subject.test).to eq "true"
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
  end

end
