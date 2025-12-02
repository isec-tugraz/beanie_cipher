use pyo3::prelude::*;
use std::collections::HashMap;

mod statistic_experiments;

#[pyfunction]
fn edp(
    rounds: usize,
    mask: u32,
) -> PyResult<(HashMap<u8, u64>, u128, (u128, u128), u32, Vec<u32>)> {
    Ok(statistic_experiments::edp(rounds, mask))
}

#[pyfunction]
fn edp_mask(
    rounds: usize,
    input_mask: u32,
    output_mask: u32,
) -> PyResult<(u32, u128, (u128, u128), u32, u32)> {
    Ok(statistic_experiments::edp_mask(
        rounds,
        input_mask,
        output_mask,
    ))
}

#[pyfunction]
fn elp(
    rounds: usize,
    mask: u32,
) -> PyResult<(HashMap<i32, u64>, u128, (u128, u128), u32, Vec<u32>)> {
    Ok(statistic_experiments::elp(rounds, mask))
}

#[pyfunction]
fn elp_mask(
    rounds: usize,
    input_mask: u32,
    output_mask: u32,
) -> PyResult<(i32, u128, (u128, u128), u32, u32)> {
    Ok(statistic_experiments::elp_mask(
        rounds,
        input_mask,
        output_mask,
    ))
}

#[pymodule]
fn beanie(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(edp, m)?)?;
    m.add_function(wrap_pyfunction!(edp_mask, m)?)?;
    m.add_function(wrap_pyfunction!(elp, m)?)?;
    m.add_function(wrap_pyfunction!(elp_mask, m)?)?;
    Ok(())
}
