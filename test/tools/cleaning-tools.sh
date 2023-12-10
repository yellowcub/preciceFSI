#!/bin/sh

error() {
    echo "Error: $1" >&2
    exit 1
}

clean_all() {
    (
        set -e -u
        cd "$1"
        echo "-- Cleaning up all cases in $(pwd)..."
        rm -rfv ./precice-run/

        for case in */; do
            if [ "${case}" = images/ ] || [ "${case}" = tools/ ]; then
                continue
            fi
            (cd "${case}" && ./clean.sh || echo "No cleaning script in ${case} - skipping")
        done
    )
}

clean_precice_logs() {
    (
        set -e -u
        cd "$1"
        echo "---- Cleaning up preCICE logs in $(pwd)"
        rm -fv ./precice-*-iterations.log \
            ./precice-*-convergence.log \
            ./precice-*-events.json \
            ./precice-*-events-summary.log \
            ./precice-postProcessingInfo.log \
            ./precice-*-watchpoint-*.log \
            ./precice-*-watchintegral-*.log \
            ./core
    )
}

clean_calculix() {
    (
        set -e -u
        cd "$1"
        echo "--- Cleaning up CalculiX case in $(pwd)"
        rm -fv ./*.cvg ./*.dat ./*.frd ./*.sta ./*.12d spooles.out dummy
        rm -fv WarnNodeMissMultiStage.nam
        rm -fv ./*.eig
        clean_precice_logs .
    )
}

clean_openfoam() {
    (
        set -e -u
        cd "$1"
        echo "--- Cleaning up OpenFOAM case in $(pwd)"
        if [ -n "${WM_PROJECT:-}" ] || error "No OpenFOAM environment is active."; then
            # shellcheck disable=SC1090 # This is an OpenFOAM file which we don't need to check
            . "${WM_PROJECT_DIR}/bin/tools/CleanFunctions"
            cleanCase
            rm -rfv 0/uniform/functionObjects/functionObjectProperties history
        fi
        rm -rfv ./preCICE-output/
        clean_precice_logs .
    )
}