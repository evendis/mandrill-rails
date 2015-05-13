require 'spec_helper'


describe Mandrill::WebHook::Image do

  context 'when given the parameters for an image file' do
    subject(:image) do
      Mandrill::WebHook::Image[{
        'name' => 'c',
        'type' => 'image/png',
        'content' => 'iVBORw0KGgoAAAA....'
      }]
    end

    it 'exposes the file correctly' do
      expect(image.name).to eql('c')
      expect(image.type).to eql('image/png')
      expect(image.base64).to eql(true)
      expect(image.content).to match(/^iVBORw0K/)
      expect(image.decoded_content).to match(/^\x89PNG\r\n/n)
    end
  end

end
