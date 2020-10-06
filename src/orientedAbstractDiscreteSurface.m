classdef orientedAbstractDiscreteSurface < abstractDiscreteSurface
% orientedAbstractDiscreteSurface 
%   (extends abstractDiscreteSurface)
%
% Adds the orientation to the Discrete surface
% which is given as an extra paramter in the constructor
% one for the edges (eo) and one for the faces (fo)
%
%

    properties (Access = protected)
        EdgeOrientation % matrix 1 x number of edges (each entry gives the orientation of the corresponding edge)
        FaceOrientation % matrix 1 x number of faces (each entry gives the orientation of the corresponding face)
    end
    properties (Dependent, Access = private)
        B0 (:,:) % adiacency matrix edges/vertices (has to be sparse)
        B1 (:,:) % adiacency matrix faces/edges (has to be sparse)
    end

    methods
        
        function obj = orientedAbstractDiscreteSurface(v,e,eo,f,fo) 
        % COSTRUTTORE
        % orientedAbstractDiscreteCurve creates a oriented abstract discrete surface
        % v has to be an non-negative integer (number of vertices)
        % e has to be a matrix with 2 rows (each column describes an edge)
        % eo has to be an array (each entry describes the orientation of an
        % edge)
        % f has to be a matrix with 3 rows (each column has to describe a face)
        % fo has to be an array (each entry describes the orientation of a face)
        % !! assume that e and eo has the same number of columns !!
        % !! assume that f and fo has the same number of columns !!
            obj@abstractDiscreteSurface(v,e,f);
            obj.EdgeOrientation  = eo;  
            obj.FaceOrientation  = fo; 
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
                        value(i, j) = obj.EdgeOrientation(j)* -1; 
                    end
                    if i == obj.Edges(2,j)
                        value(i, j) = obj.EdgeOrientation(j)* 1; 
                    end
                end
            end
        end
        
        function value = get.B1(obj)
        % Construction of the second adiacency matrix (edges/faces)
            value = sparse(obj.nEdges, obj.nFaces);
                   value = sparse(obj.nEdges,obj.nFaces);
            for i = 1 : obj.nFaces
                for j = 1 : obj.nEdges
                    % controllo per ogni edge del simplesso se esso ha
                    % orientazione concorde a quella della faccia,
                    % informaizone conteuta nella matrice fo. in caso
                    % affermativo nella metrice di adiacenza compare 1
                    % altrimenti -1.
                    if all(obj.Edges(:,j) == obj.Faces([1,2], i)) || ...
                                 all(obj.Edges(:,j) == obj.Faces([2,3], i))
                        value(j,i) = obj.EdgeOrientation(j) * obj.FaceOrientation(i);
                    end             
                    if all(obj.Edges(:,j) == obj.Faces([1,3], i))
                        value(j,i) = -1 * obj.EdgeOrientation(j) * obj.FaceOrientation(i);
                    end
                end 
            end
        end

        function e = edgeOrientation(obj)
        % returns the orientation of the edges
            e = obj.EdgeOrientation;
        end
        
        function e = faceOrientation(obj)
        % returns the orietation of the faces
            e = obj.FaceOrientation;
        end
        
        function b = firstAdiacencyMatrix(obj)
        % returns the adiacency matrix involving vertices and edges
            b = obj.B0;
        end
        
        function b = secondAdiacencyMatrix(obj)
        % returns the adiacency matrix involving edges and faces
            b = obj.B1;
        end
        
        function tf = hasConsistentOrientation(obj)
        % returns true if the surface has a consinstent orientation, false otherwise
            % per verificare che una superficie ha orienatatamento non consistente, 
            % la somma di almeno una riga di B1 deve essere -2 o 2
            tf = ~any(ismember([2 -2], sum(obj.B1, 2)));
        end
        
       function disp(obj)
        % displays the object
            fprintf('Oriented abstract discrete surface: %d vertices, %d edges, %d faces.\n\n',obj.nVertices,obj.nEdges,obj.nFaces);
       end
        
    end
end
