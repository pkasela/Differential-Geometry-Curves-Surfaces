classdef simplicial1Complex
    % simplicial1Complex 
    % 
    % The object created is a 1 - simplicial complex which is created using
    % the number of vertices (v) and the edges (e) where the edges must be a 
    % matrix 2 x number of vertices with each column representing the segment
    % formed by using the vertices for example [1 2] is a segment that connects
    % the vertice 1 to the vertice 2, the orientation does not matter in this case
    %
  
    properties (Access = protected)
        nVertices 
        Vertices (1,:) % matrix 1 x number of vertices   
        nEdges
        Edges (2,:) (each column corresponds to an edge with ordered < indices)
    end
    properties (Dependent, Access = private)
        B0 (:,:) % adiacency matrix edges/vertices (SPARSE)
    end
    
    
    methods
        
        function obj = simplicial1Complex(v,e) % COSTRUTTORE
        % Creates a 1-dimensional simplicial complex
        % v has to be an non-negative integer (number of vertices)
        % e has to be a matrix with 2 rows (each column has to describe an edge)
        % TODO:
        % add and throw error in case of any rule violations for example number of vertices < 1
        
            obj.nVertices = v;
            obj.Vertices = (1:v); 
            obj.nEdges = size(e,2); %numero di colonne della matrice degli edges
            obj.Edges = sort(e,1); %ordina elementi delle colanne in modo crescente         
        end 

        function value = get.B0(obj)
        % Computation of the first adiacency matrix (vertices/edges)
            value = sparse(obj.nVertices, obj.nEdges);
            for i=1:obj.nVertices
                for j=1:obj.nEdges
                    if i == obj.Edges(1,j) || i == obj.Edges(2,j)
                        value(i, j) = 1;
                    end    
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
        
        function b = firstAdiacencyMatrix(obj)
        % Returns the adiacency matrix involving vertices and edges
            b = obj.B0;
        end
        
        function st = simplicialStar(obj, v)
        % Returns the simplicial star of the vertex v
           edges_index = obj.B0(v,:);
           [line, column, value] = find(edges_index);
           
           st = containers.Map({'vertices', 'edges'}, {v, obj.Edges(:,column)});
           fprintf("Vertices = [%d]\n", st("vertices"));
           fprintf("Edges\n");
           fprintf("[%d %d] \n", st("edges"));           
        end
        
        function cl = simplicialStarClosure(obj, v)
        % Returns the closure of simplicial star of the vertex v
           st = simplicialStar(obj, v);
           lk = link(obj, v);
           
           cl = containers.Map({'vertices', 'edges', 'link'},{st('vertices'), st('edges'), lk});
                               
           
        end
        
        function lk = link(obj, v)
        % Returns the link of the vertex v
           edges_index = obj.B0(v,:);
           [line, column, value] = find(edges_index);
           edges = obj.Edges(:,column);
           
           lk = [];
           for i = 1:length(edges)
               if v == edges(1,i)
                   lk = [lk, edges(2,i)];
               else
                   lk = [lk, edges(1,i)];
               end
           end
           fprintf("Link: ");
           fprintf("[%d] ", lk);
           fprintf("\n")
        end
        
        function tf = isPure(obj)
        % Returns true if the 1-complex is pure of dimension 1, false otherwise
            % all we need to check is if the all the vertex are in
            % atleast one segment and to do that we need to check whether 
            % the rowsum of B0 matrix contains 0 or not, if it contains 0
            % then atleast one vertices is not contained in any edge.
            
             tf = ~ismember(0, full(sum(obj.B0, 2)));
        end
        
        function tf = isCurve(obj)
        % Returns true if the 1-complex is a discrete curve, false otherwise
           % all we need to check is that no vertices is contained in 
           % more than two edges and it is atleast contained in one edge.
           tf = isPure(obj) && ~any(full(sum(obj.B0, 2)) > 2);
        end
        
        function disp(obj)
        % Displays the object
            fprintf('1-simplicial complex: %d vertices, %d edges.\n\n',obj.nVertices, obj.nEdges);
        end
        
    end
end
