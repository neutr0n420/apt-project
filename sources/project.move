module MedicalModule::PatientTreatment {
    use std::string::{Self, String};
    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Error codes
    const ERROR_NOT_AUTHORIZED: u64 = 1;
    const ERROR_TREATMENT_NOT_FOUND: u64 = 2;
    
    /// Struct representing a patient's treatment plan
    struct Treatment has key, store {
        patient_id: String,
        diagnosis: String,
        medication: String,
        start_date: u64,
        doctor_address: address
    }
    
    /// Resource to track a doctor's patients
    struct Doctor has key {
        patient_count: u64
    }
    
    /// Function to register a new doctor
    public entry fun register_doctor(account: &signer) {
        let doctor_data = Doctor {
            patient_count: 0
        };
        move_to(account, doctor_data);
    }
    
    /// Function to create a new treatment plan for a patient
    public entry fun create_treatment(
        doctor: &signer,
        patient_id: String,
        diagnosis: String,
        medication: String
    ) acquires Doctor {
        let doctor_addr = signer::address_of(doctor);
        
        // Ensure the doctor is registered
        assert!(exists<Doctor>(doctor_addr), ERROR_NOT_AUTHORIZED);
        
        let treatment = Treatment {
            patient_id,
            diagnosis,
            medication,
            start_date: timestamp::now_seconds(),
            doctor_address: doctor_addr
        };
        
        // Update doctor's patient count
        let doctor_data = borrow_global_mut<Doctor>(doctor_addr);
        doctor_data.patient_count = doctor_data.patient_count + 1;
        
        // Store the treatment under the patient's address
        move_to(doctor, treatment);
    }
    
    /// Function to update an existing treatment plan
    public entry fun update_treatment(
        doctor: &signer,
        patient_address: address,
        new_medication: String
    ) acquires Treatment {
        let doctor_addr = signer::address_of(doctor);
        
        // Ensure the treatment exists and belongs to this doctor
        assert!(exists<Treatment>(patient_address), ERROR_TREATMENT_NOT_FOUND);
        
        let treatment = borrow_global_mut<Treatment>(patient_address);
        assert!(treatment.doctor_address == doctor_addr, ERROR_NOT_AUTHORIZED);
        
        // Update the medication
        treatment.medication = new_medication;
    }
}