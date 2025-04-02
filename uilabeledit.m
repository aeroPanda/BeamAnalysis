classdef uilabeledit < handle
    properties
        uiLabel
        uiEdit
        uiGrid
        uiParent
    end

    methods
        function obj = uilabeledit(uiParent,varargin)
            r = 1;  c = 1;
            obj.uiParent = uiParent;
            if isa(uiParent,'matlab.ui.container.GridLayout')
                obj.uiGrid = uiParent;
                switch nargin
                    case 2
                        r = varargin{1};
                    case 3
                        r = varargin{1};  c = varargin{2};
                end
            elseif isa(uiParent,'matlab.ui.container.Panel') || isa(uiParent,'matlab.ui.Figure')
                obj.uiGrid = uigridlayout('Parent',uiParent, ...
                'RowHeight',24, ...
                'ColumnWidth',{30,'1x'});
            else
                obj.uiGrid = uigridlayout('Parent',uiParent, ...
                'RowHeight',24, ...
                'ColumnWidth',{30,'1x'});
            end

            uiLabel = uilabel('Parent',obj.uiGrid, 'HorizontalAlignment','left');
            obj.uiLabel = uiLabel;
            uiLabel.Layout.Row = r;  uiLabel.Layout.Column = c;

            uiEdit = uieditfield('numeric','Parent',obj.uiGrid);
            obj.uiEdit = uiEdit;
            uiEdit.Layout.Row = r;  uiEdit.Layout.Column = c+1;            
        end
    end
end