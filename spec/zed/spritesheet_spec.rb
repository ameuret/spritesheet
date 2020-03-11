RSpec.describe Zed::Spritesheet do
  it "has a version number (SEMVER 2.0.0)" do
    expect(Zed::Spritesheet::VERSION).not_to be nil
  end

  
  describe '.new(pathBaseName, useExternalFiles = false)' do
    it 'loads an XML description' do
      ZED::SpriteSheet.new 'citydetails'
    end

    it 'recognizes the ShoeBox JSON format' do
      pending 'figuring out ShoeBox\'s lingo on frames'
      raise
    end

    it 'supports full path + base name specification' do
      ss = ZED::SpriteSheet.new 'spec/assets/city/citydetails'
      expect(ss.path).to eq('spec/assets/city/')
      expect(ss.baseName).to eq('citydetails')
    end

    it 'supports simple file base name specification' do
      ss = ZED::SpriteSheet.new 'citydetails'
      expect(ss.path).to eq('')
      expect(ss.baseName).to eq('citydetails')
    end

    it 'supports external sprites files' do
      expect do
        ZED::SpriteSheet.new 'spec/assets/citydetails-missingRef', true
      end.to raise_error Errno::ENOENT
    end
  end

  describe '#sprites' do
    it 'gives access to all entries found in the XML metadata' do
      ss = ZED::SpriteSheet.new 'citydetails'
      expect(ss.sprites["cityDetails_007"][:x]).to eq(103)
      expect(ss.sprites["cityDetails_007"][:y]).to eq(64)
      expect(ss.sprites["cityDetails_007"][:w]).to eq(22)
      expect(ss.sprites["cityDetails_007"][:h]).to eq(37)
    end
  end  

  describe '#[name]' do
    it 'returns a Hash featuring DragonRuby\'s tiling keys' do
      baseName =  'citydetails'
      ss = ZED::SpriteSheet.new baseName
      h = ss["cityDetails_007"]
      expect(h[:path]).to eq(baseName + '.png')
      expect(h[:tile_x]).to eq(103)
      expect(h[:tile_y]).to eq(64)
      expect(h[:tile_w]).to eq(22)
      expect(h[:tile_h]).to eq(37)
    end
    
    it 'honors the base path for individual sprite files' do
      baseName =  'spec/assets/city/citydetails'
      ss = ZED::SpriteSheet.new baseName, true
      h = ss["cityDetails_007"]
      expect(h[:path]).to eq('spec/assets/city/cityDetails_007' + '.png')
    end  
  end

  describe '#export' do
    it 'generates a Ruby source file describing the sprite sheet' do
      baseName =  'spec/assets/city/citydetails'
      ss = ZED::SpriteSheet.new baseName
      ss.export
      expect(File).to exist(baseName + '.rb')
    end

    it 'creates a Hash literal under the SpriteSheet::<basename> namespace' do
      baseName =  'spec/assets/city/citydetails'
      ss = ZED::SpriteSheet.new baseName
      ss.export
      src = File.read(baseName + '.rb')
      expect(src).to include 'module SpriteSheet'
      expect(src).to include "module #{ss.baseName.capitalize}"
      expect(src).to include "cityDetails_000\"=>{:path=>\"spec/assets/city/cityDetails_000.png\", :x=>125, :y=>64, :w=>22, :h=>37}"
    end

    it 'can set a specific path instead of using the input atlas path' do
      baseName =  'spec/assets/city/citydetails'
      ss = ZED::SpriteSheet.new baseName
      ss.export '../sprites/city'
      src = File.read(baseName + '.rb')
      expect(src).to include "cityDetails_000\"=>{:path=>\"../sprites/city/cityDetails_000.png\", :x=>125, :y=>64, :w=>22, :h=>37}"
    end

  end
end
