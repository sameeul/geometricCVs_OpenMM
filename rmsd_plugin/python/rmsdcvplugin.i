%module RMSDCVplugin
%include "factory.i"

%{
#include "RMSDCVForce.h"
#include "OpenMM.h"
#include "OpenMMAmoeba.h"
#include "OpenMMDrude.h"
#include "openmm/RPMDIntegrator.h"
#include "openmm/RPMDMonteCarloBarostat.h"
#include "openmm/Vec3.h"
%}

%{
#include <numpy/arrayobject.h>
%}

%include "std_vector.i"
%include "typemaps.i"
%include "header.i"
%include "numpy.i"

%import(module="openmm") "swig/OpenMMSwigHeaders.i"
%include "swig/typemaps.i"



//#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION
/*
 * The following lines are needed to handle std::vector.
 * Similar lines may be needed for vectors of vectors or
 * for other STL types like maps.
 */
using namespace OpenMM;
//%include "std_vector.i"
namespace std {
  %template(vectord) vector<double>;
  %template(vectori) vector<int>;
};

%pythoncode %{
import openmm as mm
import simtk.unit as unit
%}

/*
 * Add units to function outputs.
*/

// %pythonappend RMSDCVPlugin::RMSDCVForce::getReferencePositions() const %{
//     val = unit.Quantity(val, unit.nanometer)
// %}

/*
 * Convert C++ exceptions to Python exceptions.
*/
%exception {
    try {
        $action
    } catch (std::exception &e) {
        PyErr_SetString(PyExc_Exception, const_cast<char*>(e.what()));
        return NULL;
    }
}

namespace RMSDCVPlugin {

class RMSDCVForce : public OpenMM::Force {
public:
    %apply (int* IN_ARRAY1, int DIM1) {(const int* p, int p_sz)};
    RMSDCVForce(const std::vector<Vec3> &referencePositions, const int* p, int p_sz);
    void setParticles(const int* p, int p_sz);    
    %clear (const int* p, int p_sz);
    virtual bool usesPeriodicBoundaryConditions() const;

    void setReferencePositions(const std::vector<Vec3> &positions);
    %apply OpenMM::Context & OUTPUT {OpenMM::Context & context };    
    void updateParametersInContext(OpenMM::Context& context);
    %clear Context & context;
    const std::vector<int>& getParticles() const;
    const std::vector<Vec3>& getReferencePositions() const;



   /*
     * Add methods for casting a Force to an RMSDCVForce.
    */
    %extend {
        static RMSDCVPlugin::RMSDCVForce& cast(OpenMM::Force& force) {
            return dynamic_cast<RMSDCVPlugin::RMSDCVForce&>(force);
        }

        static bool isinstance(OpenMM::Force& force) {
            return (dynamic_cast<RMSDCVPlugin::RMSDCVForce*>(&force) != NULL);
        }
    }

};

}
