#include <iostream>
#include "GimicInterface.h"
#include "gimic_interface.h"

using namespace std;

GimicInterface::GimicInterface(const char *mol, const char *xdens) {
    gimic_init(mol, xdens);
}

GimicInterface::~GimicInterface() {
    gimic_finalize();
}

void GimicInterface::set_uhf(int uhf) {
    gimic_set_uhf(&uhf);
}

void GimicInterface::set_magnet(const double b[3]) {
    gimic_set_magnet(b);
}

void GimicInterface::set_spin(char *s) {
    gimic_set_spin(s);
}

void GimicInterface::set_screening(double thrs) {
    gimic_set_screening(&thrs);
}

void GimicInterface::calc_jtensor(const double r[3], double jt[9]) {
    gimic_calc_jtensor(r, jt);
}

void GimicInterface::calc_jvector(const double r[3], double jv[3]) {
    gimic_calc_jvector(r, jv);
}

void GimicInterface::calc_modj(const double r[3], double *mj) {
    gimic_calc_modj(r, mj);
}

