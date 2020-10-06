classdef abstractDiscreteCurve < simplicial1Complex
% abstractDiscreteCurve 
%   (extends simplicial1Complex)
%
% It generalizes the 1-simplex adding a check if 
% the curve has a boundry which will be needed 
% later on.
%

    methods
        
        function obj = abstractDiscreteCurve(v,e)
        % Creates an abstract discrete curve
        % v has to be an non-negative integer (number of vertices)
        % e has to be a matrix with 2 rows (each column describes an edge)
            obj@simplicial1Complex(v,e);
            if ~obj.isCurve()
                error('Error. Input is not a discrete curve.');
            end               
        end 
               
        function tf = hasBoundary(obj)
        % Returns true if the curve has boundary, false otherwise
            % all we need to check is that a vertices is
            % contained in only one edge (since we already
            % know that it is a curve.
            tf = ismember(1, full(sum(firstAdiacencyMatrix(obj), 2)));
        end
        
       function disp(obj)
        % Displays the object
            fprintf('Abstract discrete curve: %d vertices, %d edges.\n\n',obj.nVertices, obj.nEdges);
        end
    end
    
end
