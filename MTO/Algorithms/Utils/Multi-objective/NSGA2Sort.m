function [rank, FrontNo, CrowdDis] = NSGA2Sort(population)
CVs = sum(max(0, Cons(population)), 2);
FrontNo = NDSort(Objs(population), CVs, inf);
CrowdDis = CrowdingDistance(Objs(population), FrontNo);
[~, rank] = sortrows([FrontNo', -CrowdDis']);
end
