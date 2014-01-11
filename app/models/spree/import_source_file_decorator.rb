module Spree
  ImportSourceFile.class_eval do
    def imported_to_lightspeed?
      variants.all?{|v| v.ls_id.present? } 
    end
  end
end
