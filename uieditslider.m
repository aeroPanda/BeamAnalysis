classdef uieditslider < handle
    properties
        uiEdit
        uiSlider
        
        uiParent
        uiGrid
        appParent        
    end
    
    methods
        function obj = uieditslider(uiParent,locationMinMax)
            if ~exist('locationMinMax','var')
                locationMinMax = [0 100];
            end
            
            uiGrid = uigridlayout('Parent',uiParent, ...
                'RowHeight',{20,24}, ...
                'ColumnWidth',{'1x'});
            obj.uiGrid = uiGrid;
            uiE = uieditfield('numeric','Parent',uiGrid, ...
                'Limits',locationMinMax, ...
                'Tag','editMassLocation', ...
                'ValueChangedFcn',@(src,evt)obj.updateLocation(src,evt));
            obj.uiEdit = uiE;
            uiE.Layout.Row = 1;  uiE.Layout.Column = 1;
            
            uiS = uislider('Parent',uiGrid, ...
                'Limits',locationMinMax, ...
                'Tag','sliderMassLocation', ...
                'ValueChangedFcn',@(src,evt)obj.updateLocation(src,evt));
            obj.uiSlider = uiS;
            uiS.Layout.Row = 2;  uiS.Layout.Column = 1;
        end
        
        function updateLocation(obj,src,evt)            
            switch src.Tag
                case 'editMassLocation'
                    uiS = obj.uiSlider;  % findobj(src.Parent.Children,'Tag','sliderMassLocation');
                    uiS.Value = src.Value;
                case 'sliderMassLocation'
                    uiE = obj.uiEdit;  % findobj(src.Parent.Children,'Tag','editMassLocation');
                    uiE.Value = src.Value;
            end
        end
    end
end