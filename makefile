# This is only important if MACHINE wasn't set
MACHINE?=macports

#GCC Macports
ifeq ($(MACHINE),macports)
	FC=mpif90
	COMP_OPT = -O2 -fexternal-blas -fallow-argument-mismatch
	LIBS = -L/usr/lib -L/opt/local/lib -lopenblas -lscalapack
	MPI_RUN  = mpiexec
	MPI_RUN_OPTS = -np 2
endif

#Intel Raven/Cobra
ifeq ($(MACHINE),$(filter $(MACHINE),cobra raven))
	FC = mpiifort
	COMP_OPT = -I${MKLROOT}/include/intel64/lp64 -I$(MKL_HOME)/include \
            -O2 -assume noold_unit_star \
            -xCORE-AVX512 -qopt-zmm-usage=high -fp-model strict -ip
	LIBS = ${MKLROOT}/lib/intel64/libmkl_blas95_lp64.a \
             ${MKLROOT}/lib/intel64/libmkl_lapack95_lp64.a \
             ${MKLROOT}/lib/intel64/libmkl_scalapack_lp64.a \
             -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a \
             ${MKLROOT}/lib/intel64/libmkl_sequential.a \
             ${MKLROOT}/lib/intel64/libmkl_core.a \
             ${MKLROOT}/lib/intel64/libmkl_blacs_intelmpi_lp64.a \
             -Wl,--end-group -lpthread -lm -ldl
	MPI_RUN  = srun
	ifeq ($(MACHINE),raven)
		MPI_RUN_OPTS = --nodes=1 --ntasks-per-node=72 --time=0:30:00 -p express
	else ifeq ($(MACHINE),cobra)
		MPI_RUN_OPTS = --nodes=1 --ntasks-per-node=40 --time=0:30:00 -p express
	endif
endif

###########################################################################
# Note MagTense is no longer needed or used (kept for historical reasons#
#MAGTENSE_DIR = $(MAGTENSE_PATH)
#MAGTENSE_INC = -I$(MAGTENSE_DIR)/source/NumericalIntegration/NumericalIntegration/ \
#    -I$(MAGTENSE_DIR)/source/TileDemagTensor/TileDemagTensor/ \
#    -I$(MAGTENSE_DIR)/source/DemagField/DemagField/
#MAGTENSE_LIB = $(MAGTENSE_DIR)/source/DemagField/DemagField/libDemagField.a \
#	$(MAGTENSE_DIR)/source/TileDemagTensor/TileDemagTensor/libTileDemagTensor.a \
#	$(MAGTENSE_DIR)/source/NumericalIntegration/NumericalIntegration/libNumericalIntegration.a
###########################################################################


# STELLOPT STUFF
LIBSTELL_INC = -I$(STELLOPT_PATH)/LIBSTELL/Release
LIBSTELL_LIB = $(STELLOPT_PATH)/LIBSTELL/Release/libstell.a

# FLAGS
FFLAGS= $(LIBSTELL_INC)
LDFLAGS=$(LIBSTELL_LIB)

OBJ=mumaterial_test.o

EXE=xmumat_test

%.o: %.f90
	$(FC) -c -o $@ $< $(FFLAGS) $(COMP_OPT)

$(EXE): $(OBJ)
	$(FC) -o $@ $^ $(LDFLAGS) $(LIBS) $(COMP_OPT)

run: $(EXE)
	$(MPI_RUN) $(MPI_RUN_OPTS) $(EXE) -mumat sphere_mu.dat

clean:
	-rm *.o $(EXE)
