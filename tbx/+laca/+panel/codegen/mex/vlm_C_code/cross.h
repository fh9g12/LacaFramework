/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * cross.h
 *
 * Code generation for function 'cross'
 *
 */

#pragma once

/* Include files */
#include "rtwtypes.h"
#include "vlm_C_code_types.h"
#include "emlrt.h"
#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function Declarations */
void cross(const emlrtStack *sp, const emxArray_real_T *a,
           const emxArray_real_T *b, emxArray_real_T *c);

/* End of code generation (cross.h) */
