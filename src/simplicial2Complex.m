classdef simplicial2Complex
    % simplicial2Complex 
    % 
    % The object created is a 2 - simplicial complex which is created using
    % the number of vertices (v) and the edges (e) where the edges must be a 
    % matrix 2 x number of vertices with each column representing the segment
    % formed by using the vertices for example [1 2] is a segment that connects
    % the vertice 1 to the vertice 2 and the faces (f) as a 3 x number of faces 
    % matrix with each column containing the vertices that create the face, 
    % the orientation does not matter in this case
    %
    %
    
    properties (Access = protected)
        nVertices % number of vertices   
        Vertices (1,:) % matrix 1 x number of vertices
        nEdges % number of edges
        Edges (2,:) % matrix 2 x number of edges (each column corresponds to an edge with ordered < indices)
        nFaces % number of faces
        Faces (3,:) % matrix 3 x number of faces (each column corresponds to a face with ordered < indices)
    end
    properties (Dependent, Access = private)
        B0 (:,:) % adiacency matrix edges/vertices (sparse)
        B1 (:,:) % adiacency matrix faces/edges (sparse)
    end
    
    methods
        
        function obj = simplicial2Complex(v,e,f)  % COSTRUTTORE
        % Creates a 2-dimensional simplicial complex
        % v has to be an non-negative integer (number of vertices)
        % e has to be a matrix with 2 rows (each column has to describe an edge)
        % f has to be a matrix with 3 rows (each column has to describe a face)
            obj.nVertices = v;
            obj.Vertices = (1:v);
            obj.nEdges = size(e,2);
            obj.Edges = sort(e,1);
            obj.nFaces = size(f,2);
            obj.Faces = sort(f,1);              
        end 
        
        function value = get.B0(obj)
        % Construction of the first adiacency matrix (vertices/edges)
            value = sparse(obj.nVertices, obj.nEdges);
            for i=1:obj.nVertices
                for j=1:obj.nEdges
                    if i == obj.Edges(1,j) || i == obj.Edges(2,j)
                        value(i, j) = 1; %valore della matrice b0 relativo a riga i e colonna j è 1
                    end    
                end
            end
        end
        
        function value = get.B1(obj)
        % Construction of the second adiacency matrix (edges/faces)
            value = sparse(obj.nEdges,obj.nFaces);
            for i = 1 : obj.nFaces
                for j = 1 : obj.nEdges
                    % controllo per ogni edge del simplesso se esso compare
                    % nelle facce e nel caso positivo value assume valore 1
                    value(j,i) = all(obj.Edges(:,j) == obj.Faces([1,2], i)) || ...
                                 all(obj.Edges(:,j) == obj.Faces([2,3], i)) || ...
                                 all(obj.Edges(:,j) == obj.Faces([1,3], i)); 
                end 
            end
        end
        
        function v = numberOfVertices(obj)
        % Returns the number of vertices
            v = obj.nVertices;
        end
        
        function v = vertices(obj)
        % Returns the set of vertices
            v = obj.Vertices;
        end
        
        function v = numberOfEdges(obj)
        % Returns the number of edges
            v = obj.nEdges;
        end
        
        function e = edges(obj)
        % Returns the set of edges
            e = obj.Edges;
        end
        
        function v = numberOfFaces(obj)
        % Returns the number of faces
            v = obj.nFaces;
        end
        
        function e = faces(obj)
        % Returns the set of faces
            e = obj.Faces;
        end
        
        function b = firstAdiacencyMatrix(obj)
        % Returns the adiacency matrix involving vertices and edges
            b = obj.B0;
        end
        
        function b = secondAdiacencyMatrix(obj)
        % Returns the adiacency matrix involving edges and faces
            b = obj.B1;
        end
        
        function st = simplicialStar(obj, v)
        % Returns the simplicial star of the vertex v
            edges_index = obj.B0(v,:);
            [line, edge_column, value] = find(edges_index);
            faces_index = obj.B1(edge_column, :);
            [line, face_column, value] = find(faces_index);
            face_column = unique(face_column); %elimina duplicati
            st = containers.Map({'vertices', 'edges', 'faces'}, ...
                                {v, obj.Edges(:,edge_column), obj.Faces(:,face_column)});
            fprintf("Vertices = [%d]\n", st("vertices"));
            fprintf("Edges\n");
            fprintf("[%d %d] \n", st("edges"));
            fprintf("Faces\n");
            fprintf("[%d %d %d] \n", st("faces"));
        end
        
        function cl = simplicialStarClosure(obj, v)
        % Returns the closure of simplicial star of the vertex v
            st = simplicialStar(obj, v);
            lk = link(obj, v);
            
            cl = containers.Map({'vertices', 'edges', 'faces', ...
                                 'linkVerices', 'linkEdges'},...
                                 {st('vertices'), st('edges'), st('faces'),...
                                  lk('vertices'), lk('edges')});
        end
        
        function lk = link(obj, v)
        % Returns the link of the vertex v
           edges_index = obj.B0(v,:);
           [line, column, value] = find(edges_index);
           faces_index = obj.B1(column, :);
           [line, face_column, value] = find(faces_index);
           face_column = unique(face_column); %elimina duplicati
           
           edges = obj.Edges(:,column);
           vertices = [];
           for i = 1:length(edges)
               if v == edges(1,i)
                   vertices = [vertices, edges(2,i)];
               else
                   vertices = [vertices, edges(1,i)];
               end
           end
           [line, column, val] = find(obj.B0(vertices, :));
           column = unique(column);
           edges = [];
           for i = 1:length(column)
               edge = obj.Edges(:,i);
               if ismember(v, edge) == 0 && any(full(obj.B1(i, face_column))) == 1
                   edges = [edges edge];
               end    
           end
           fprintf("\nLink: \n");
           fprintf("Vertices: ");
           fprintf("[%d] ", vertices);
           fprintf("\nEdges:\n")
           fprintf("[%d %d]\n", edges);
           lk = containers.Map({'vertices','edges'},...
                                {vertices, edges});
        end
        
        function tf = isPure(obj)
        % Returns true if the complex is pure of dimension 2, false otherwise
            % all we need to check is whether the vertices are in atleast 
            % one edge (using the B0 matrix rowSum > 0) and same for the 
            % edges in faces but using B1 matrix.
            
            tf1 = ~ismember(0, full(sum(obj.B0, 2)));
            tf2 = ~ismember(0, full(sum(obj.B1, 2)));
            tf = (tf1 && tf2);
        end
        
        function tf = isSurface(obj)
        % Returns true if the complex is a discrete surfaces, false otherwise
            % Check if it's pure and an edge cannot be in more than
            % two faces for it be to a surface
            tf = isPure(obj) && ~any(sum(obj.B1, 2) > 2);
        end
        
        function disp(obj)
         % Displays the object
            fprintf('2-simplicial complex: %d vertices, %d edges, %d faces.\n\n',obj.nVertices,obj.nEdges,obj.nFaces);
        end
    end
end
