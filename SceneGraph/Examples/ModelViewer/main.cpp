#include <iostream>
#include <chrono>
#include <thread>
#include <Eigen/Eigen>

#include <pangolin/pangolin.h>
#include <SceneGraph/SceneGraph.h>

using namespace std;

void Usage() {
    cout << "Usage: ModelViewer filename" << endl;
}

int main( int argc, char* argv[] )
{
    if(argc != 2) {
        Usage();
        exit(-1);
    }

    const std::string model_filename(argv[1]);

    // Create OpenGL window in single line thanks to GLUT
    pangolin::CreateWindowAndBind("Main",640,480);
    SceneGraph::GLSceneGraph::ApplyPreferredGlSettings();
    glClearColor( 0,0,0,0);
    glewInit();

    // Scenegraph to hold GLObjects and relative transformations
    SceneGraph::GLSceneGraph glGraph;

    SceneGraph::GLLight light(10,10,-100);
    glGraph.AddChild(&light);

    SceneGraph::GLGrid grid(10,1,true);
    glGraph.AddChild(&grid);

    SceneGraph::AxisAlignedBoundingBox bbox;
    
#ifdef HAVE_ASSIMP
    // Define a mesh object and try to load model
    SceneGraph::GLMesh glMesh;
    try {
        glMesh.Init(model_filename);
        glGraph.AddChild(&glMesh);
        bbox = glMesh.ObjectAndChildrenBounds();
    }catch(exception e) {
        cerr << "Cannot load mesh." << endl;
        cerr << e.what() << std::endl;
        exit(-1);
    }
#endif // HAVE_ASSIMP

    
    const Eigen::Vector3d center = bbox.Center();
    double size = bbox.Size().norm();
   
    // Define Camera Render Object (for view / scene browsing)
    pangolin::OpenGlRenderState stacks3d(
        pangolin::ProjectionMatrix(640,480,420,420,320,240, 0.01, 1000),
        pangolin::ModelViewLookAt(center(0), center(1) + size, center(2) + size/4, center(0), center(1), center(2), pangolin::AxisZ)
    );

    // We define a new view which will reside within the container.
    pangolin::View view3d;

    // We set the views location on screen and add a handler which will
    // let user input update the model_view matrix (stacks3d) and feed through
    // to our scenegraph
    view3d.SetBounds(0.0, 1.0, 0.0, 1.0, -640.0f/480.0f)
          .SetHandler(new SceneGraph::HandlerSceneGraph(glGraph,stacks3d))
          .SetDrawFunction(SceneGraph::ActivateDrawFunctor(glGraph, stacks3d));

    // Add our views as children to the base container.
    pangolin::DisplayBase().AddDisplay(view3d);

    // Default hooks for exiting (Esc) and fullscreen (tab).
    while( !pangolin::ShouldQuit() )
    {
        // Clear whole screen
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Swap frames and Process Events
        pangolin::FinishFrame();

        // Pause for 1/60th of a second.
        std::this_thread::sleep_for(std::chrono::milliseconds(1000 / 60));
    }

    return 0;
}
