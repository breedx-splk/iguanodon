import http from "k6/http";
import { check } from "k6";
import names from "./names.js";

export default function() {
//    const url = "http://localhost:9966/petclinic/api/pettypes";
    const baseUri = "http://localhost:9966/petclinic/api";
    const url = `${baseUri}/specialties`;
    const specialtiesResponse = http.get(url);
    const specialties = JSON.parse(specialtiesResponse.body);

    const newVet = names.randomVet(specialties);
    console.log(JSON.stringify(newVet));
    const response = http.post(`${baseUri}/vets`, JSON.stringify(newVet),
            { headers: { 'Content-Type': 'application/json' } });

    console.log(JSON.stringify(response))
    let checkRes = check(response, {
            "status is 201": (r) => r.status === 201
        });

        // We reverse the check() result since we want to count the failures
//    failureRate.add(!checkRes);
};