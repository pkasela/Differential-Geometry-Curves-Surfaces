classdef orientedAbstractDiscreteCurve < abstractDiscreteCurve
% orientedAbstractDiscreteCurve 
%   (extends abstractDiscreteCurve)
%
% Adds the orientations to the Discrete curve, in this case
% the orientation is given as an extra parameter: with an 
% array with 1 for positive and -1 for negative parameter 
%
%

    properties (Access = protected)
        EdgeOrientation % matrix 1 x number of edges (each entry gives the orientation of the corresponding edge)
    end
    properties (Dependent, Access = private)
        B0 (:,:) % adiacency matrix edges/vertices (SPARSE)
    end
    
    methods
        
        function obj = orientedAbstractDiscreteCurve(v,e,eo) % COSTRUTTORE
        % Creates an oriented abstract discrete curve
        % v has to be an non-negative integer (number of vertices)
        % e has to be a matrix with 2 rows (each column describes an edge)
        % eo has to be an array (each entry describes the orientation of an
        % edge)
        % !! assume that e and eo has the same number of columns !!
            obj@abstractDiscreteCurve(v,e);
            obj.EdgeOrientation  = eo;           
        end
        
        function value = get.B0(obj)
        % Construction of the first adiacency matrix (vertices/edges)
            value = sparse(obj.nVertices, obj.nEdges);
            for i=1:obj.nVertices
                for j=1:obj.nEdges
                    if i == obj.Edges(1,j)
                        %nella magtrice di adiacenza deve esserci -1 o 1 in
                        %base all' orientazione. Siccome gli spigoli sono 
                        %ordinati nelle matrici moltiplico per -1 o 1 orientazione, 
                        %che è un informazione contenuta nella matrice eo.
                        value(i, j) = obj.EdgeOrientation(j) * -1; 
                    end
                    if i == obj.Edges(2,j)
                        value(i, j) = obj.EdgeOrientation(j) * 1; 
                    end
                end
            end
        end
        
        function e = edgeOrientation(obj)
        % Returns the orientation of the edges
            e = obj.EdgeOrientation;
        end
        
        function b = firstAdiacencyMatrix(obj)
        % Returns the adiacency matrix involving vertices and edges
            b = obj.B0;
        end
        
        function tf = hasConsistentOrientation(obj)
        % Returns true if the curve has a consinstent orientation, false otherwise
            % We just need to check that the rowsum of B0 does not have
            % -2 or 2.
            tf = ~any(ismember([2 -2], sum(obj.B0, 2)));
        end
        
       function disp(obj)
        % Displays the object
            fprintf('Oriented abstract discrete curve: %d vertices, %d edges.\n\n',obj.nVertices,obj.nEdges);
       end
        
    end
end
