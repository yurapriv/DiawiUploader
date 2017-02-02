# DiawiUploader

Ruby script for uploading .ipa files to www.diawi.com

### Usage
```ruby
du = DiawiUploader.new('DIAWI_TOKEN')
puts du.download_link_for_file('/FULL/PATH/TO/IPA/FILE.ipa')
```
